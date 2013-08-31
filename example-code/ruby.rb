# stdlib
require 'optparse'

# gems
require 'thor'

module Rouge
  class CLI < Thor
    default_task :highlight

    def self.start(argv=ARGV, *a)
      if argv.include? '-v' or argv.include? '--version'
        puts Rouge.version
        exit 0
      end

      unless %w(highlight style list --help -h help).include?(argv.first)
        argv.unshift 'highlight'
      end

      super(argv, *a)
    end

    desc 'highlight [FILE]', 'highlight some code'
    option :input_file, :aliases => '-i',  :desc => 'the file to operate on'
    option :lexer, :aliases => '-l',
      :desc => ('Which lexer to use.  If not provided, rougify will try to ' +
                'guess based on --mimetype, the filename, and the file ' +
                'contents.')
    option :formatter, :aliases => '-f', :default => 'terminal256',
      :desc => ('Which formatter to use.')
    option :mimetype, :aliases => '-m',
      :desc => ('a mimetype that Rouge will use to guess the correct lexer. ' +
                'This is ignored if --lexer is specified.')
    option :lexer_opts, :aliases => '-L', :type => :hash, :default => {},
      :desc => ('a hash of options to pass to the lexer.')
    option :formatter_opts, :aliases => '-F', :type => :hash, :default => {},
      :desc => ('a hash of options to pass to the formatter.')
    def highlight(file=nil)
      filename = options[:file] || file
      source = filename ? File.read(filename) : $stdin.read

      if options[:lexer].nil?
        lexer_class = Lexer.guess(
          :filename => filename,
          :mimetype => options[:mimetype],
          :source   => source,
        )
      else
        lexer_class = Lexer.find(options[:lexer])
        raise "unknown lexer: #{options[:lexer]}" unless lexer_class
      end

      formatter_class = Formatter.find(options[:formatter])

      # only HTML is supported for now
      formatter = formatter_class.new(normalize_hash_keys(options[:formatter_opts]))
      lexer = lexer_class.new(normalize_hash_keys(options[:lexer_opts]))

      puts Rouge.highlight(source, lexer, formatter)
    end

    desc 'style THEME', 'render THEME as css'
    option :scope, :desc => "a css selector to scope the styles to"
    def style(theme_name='thankful_eyes')
      theme = Theme.find(theme_name)
      raise "unknown theme: #{theme_name}" unless theme

      puts theme.new(options).render
    end

    desc 'list', 'list the available lexers, formatters, and styles'
    def list
      puts "== Available Lexers =="
      all_lexers = Lexer.all
      max_len = all_lexers.map { |l| l.tag.size }.max

      Lexer.all.each do |lexer|
        desc = "#{lexer.desc}"
        if lexer.aliases.any?
          desc << " [aliases: #{lexer.aliases.join(',')}]"
        end
        puts "%s: %s" % [lexer.tag, desc]
        puts
      end
    end

  private
    # TODO: does Thor do this for me?
    def normalize_hash_keys(hash)
      out = {}
      hash.each do |k, v|
        new_key = k.tr('-', '_').to_sym
        out[new_key] = v
      end

      out
    end
  end
end
module Rouge
  # A Formatter takes a token stream and formats it for human viewing.
  class Formatter
    # @private
    REGISTRY = {}

    # Specify or get the unique tag for this formatter.  This is used
    # for specifying a formatter in `rougify`.
    def self.tag(tag=nil)
      return @tag unless tag
      REGISTRY[tag] = self

      @tag = tag
    end

    # Find a formatter class given a unique tag.
    def self.find(tag)
      REGISTRY[tag]
    end

    # Format a token stream.  Delegates to {#format}.
    def self.format(tokens, opts={})
      new(opts).format(tokens)
    end

    # Format a token stream.
    def format(tokens)
      enum_for(:stream, tokens).to_a.join
    end

    # @deprecated Use {#format} instead.
    def render(tokens)
      warn 'Formatter#render is deprecated, use #format instead.'
      format(tokens)
    end

    # @abstract
    # yield strings that, when concatenated, form the formatted output
    def stream(tokens, &b)
      raise 'abstract'
    end
  end
end
# stdlib
require 'cgi'

module Rouge
  module Formatters
    # Transforms a token stream into HTML output.
    class HTML < Formatter
      tag 'html'

      # @option opts :css_class
      # A css class to be used for the generated <pre> tag.
      def initialize(opts={})
        @css_class = opts[:css_class] || 'highlight'
        @line_numbers = opts.fetch(:line_numbers) { false }
      end

      # @yield the html output.
      def stream(tokens, &b)
        if @line_numbers
          stream_tableized(tokens, &b)
        else
          stream_untableized(tokens, &b)
        end
      end

      def stream_untableized(tokens, &b)
        yield "<pre class=#{@css_class.inspect}>"
        tokens.each do |tok, val|
          span(tok, val, &b)
        end
        yield '</pre>'
      end

      def stream_tableized(tokens, &b)
        num_lines = 0
        code = ''

        tokens.each do |tok, val|
          num_lines += val.scan(/\n/).size
          span(tok, val) { |str| code << str }
        end

        # generate a string of newline-separated line numbers for the gutter
        numbers = num_lines.times.map do |x|
          %<<div class="lineno">#{x+1}</div>>
        end.join

        yield "<table class=#{@css_class.inspect}><tbody><tr>"

        # the "gl" class applies the style for Generic.Lineno
        yield '<td class="gutter gl"><pre>'
        yield numbers
        yield '</pre></td>'

        yield '<td class="code"><pre>'
        yield code
        yield '</pre></td>'

        yield '</tr></tbody></table>'
      end

    private
      def span(tok, val, &b)
        # TODO: properly html-encode val
        val = CGI.escape_html(val)

        case tok.shortname
        when ''
          yield val
        when nil
          raise "unknown token: #{tok.inspect}"
        else
          yield '<span class='
          yield tok.shortname.inspect
          yield '>'
          yield val
          yield '</span>'
        end
      end
    end
  end
end
module Rouge
  module Formatters
    # A formatter for 256-color terminals
    class Terminal256 < Formatter
      tag 'terminal256'

      # @private
      attr_reader :theme


      # @option opts :theme
      #   (default is thankful_eyes) the theme to render with.
      def initialize(opts={})
        @theme = opts[:theme] || 'thankful_eyes'
        @theme = Theme.find(@theme) if @theme.is_a? String
      end

      def stream(tokens, &b)
        tokens.each do |tok, val|
          escape = escape_sequence(tok)
          yield escape.style_string
          yield val
          yield escape.reset_string
        end
      end

      class EscapeSequence
        attr_reader :style
        def initialize(style)
          @style = style
        end

        def self.xterm_colors
          @xterm_colors ||= [].tap do |out|
            # colors 0..15: 16 basic colors
            out << [0x00, 0x00, 0x00] # 0
            out << [0xcd, 0x00, 0x00] # 1
            out << [0x00, 0xcd, 0x00] # 2
            out << [0xcd, 0xcd, 0x00] # 3
            out << [0x00, 0x00, 0xee] # 4
            out << [0xcd, 0x00, 0xcd] # 5
            out << [0x00, 0xcd, 0xcd] # 6
            out << [0xe5, 0xe5, 0xe5] # 7
            out << [0x7f, 0x7f, 0x7f] # 8
            out << [0xff, 0x00, 0x00] # 9
            out << [0x00, 0xff, 0x00] # 10
            out << [0xff, 0xff, 0x00] # 11
            out << [0x5c, 0x5c, 0xff] # 12
            out << [0xff, 0x00, 0xff] # 13
            out << [0x00, 0xff, 0xff] # 14
            out << [0xff, 0xff, 0xff] # 15

            # colors 16..232: the 6x6x6 color cube
            valuerange = [0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff]

            217.times do |i|
              r = valuerange[(i / 36) % 6]
              g = valuerange[(i / 6) % 6]
              b = valuerange[i % 6]
              out << [r, g, b]
            end

            # colors 233..253: grayscale
            1.upto 22 do |i|
              v = 8 + i * 10
              out << [v, v, v]
            end
          end
        end

        def fg
          return @fg if instance_variable_defined? :@fg
          @fg = style.fg && self.class.color_index(style.fg)
        end

        def bg
          return @bg if instance_variable_defined? :@bg
          @bg = style.bg && self.class.color_index(style.bg)
        end

        def style_string
          @style_string ||= begin
            attrs = []

            attrs << ['38', '5', fg.to_s] if fg
            attrs << ['45', '5', bg.to_s] if bg
            attrs << '01' if style[:bold]
            attrs << '04' if style[:italic] # underline, but hey, whatevs
            escape(attrs)
          end
        end

        def reset_string
          @reset_string ||= begin
            attrs = []
            attrs << '39' if fg # fg reset
            attrs << '49' if bg # bg reset
            attrs << '00' if style[:bold] || style[:italic]

            escape(attrs)
          end
        end

      private
        def escape(attrs)
          return '' if attrs.empty?
          "\e[#{attrs.join(';')}m"
        end

        def self.color_index(color)
          @color_index_cache ||= {}
          @color_index_cache[color] ||= closest_color(*get_rgb(color))
        end

        def self.get_rgb(color)
          color = $1 if color =~ /#([0-9a-f]+)/i
          hexes = case color.size
          when 3
            color.chars.map { |c| "#{c}#{c}" }
          when 6
            color.scan /../
          else
            raise "invalid color: #{color}"
          end

          hexes.map { |h| h.to_i(16) }
        end

        def self.closest_color(r, g, b)
          distance = 257 * 257 * 3 # (max distance, from #000000 to #ffffff)

          match = 0

          xterm_colors.each_with_index do |(cr, cg, cb), i|
            d = (r - cr)**2 + (g - cg)**2 + (b - cb)**2
            next if d >= distance

            match = i
            distance = d
          end

          match
        end
      end

    # private
      def escape_sequence(token)
        @escape_sequences ||= {}
        @escape_sequences[token.name] ||=
          EscapeSequence.new(get_style(token))
      end

      def get_style(token)
        return text_style if token.name == 'Text'

        theme.get_own_style(token) || text_style
      end

      def text_style
        style = theme.get_style(Token['Text'])
        # don't highlight text backgrounds
        style.delete :bg
        style
      end
    end
  end
end
# stdlib
require 'strscan'

module Rouge
  # @abstract
  # A lexer transforms text into a stream of `[token, chunk]` pairs.
  class Lexer
    class << self
      # Lexes `stream` with the given options.  The lex is delegated to a
      # new instance.
      #
      # @see #lex
      def lex(stream, opts={}, &b)
        new(opts).lex(stream, &b)
      end

      def default_options(o={})
        @default_options ||= {}
        @default_options.merge!(o)
        @default_options
      end

      # Given a string, return the correct lexer class.
      def find(name)
        registry[name.to_s]
      end

      # Find a lexer, with fancy shiny features.
      #
      # * The string you pass can include CGI-style options
      #
      #     Lexer.find_fancy('erb?parent=tex')
      #
      # * You can pass the special name 'guess' so we guess for you,
      #   and you can pass a second argument of the code to guess by
      #
      #     Lexer.find_fancy('guess', "#!/bin/bash\necho Hello, world")
      #
      # This is used in the Redcarpet plugin as well as Rouge's own
      # markdown lexer for highlighting internal code blocks.
      #
      def find_fancy(str, code=nil)
        name, opts = str ? str.split('?', 2) : [nil, '']

        # parse the options hash from a cgi-style string
        opts = CGI.parse(opts || '').map do |k, vals|
          [ k.to_sym, vals.empty? ? true : vals[0] ]
        end

        opts = Hash[opts]

        lexer_class = case name
        when 'guess', nil
          self.guess(:source => code, :mimetype => opts[:mimetype])
        when String
          self.find(name)
        end

        lexer_class && lexer_class.new(opts)
      end

      # Specify or get this lexer's description.
      def desc(arg=:absent)
        if arg == :absent
          @desc
        else
          @desc = arg
        end
      end

      # Specify or get the path name containing a small demo for
      # this lexer (can be overriden by {demo}).
      def demo_file(arg=:absent)
        return @demo_file = Pathname.new(arg) unless arg == :absent

        @demo_file = Pathname.new(__FILE__).dirname.join('demos', tag)
      end

      # Specify or get a small demo string for this lexer
      def demo(arg=:absent)
        return @demo = arg unless arg == :absent

        @demo = File.read(demo_file)
      end

      # @return a list of all lexers.
      def all
        registry.values.uniq
      end

      # Guess which lexer to use based on a hash of info.
      #
      # @option info :mimetype
      #   A mimetype to guess by
      # @option info :filename
      #   A filename to guess by
      # @option info :source
      #   The source itself, which, if guessing by mimetype or filename
      #   fails, will be searched for shebangs, <!DOCTYPE ...> tags, and
      #   other hints.
      #
      # @see Lexer.analyze_text
      def guess(info={})
        by_mimetype = guess_by_mimetype(info[:mimetype]) if info[:mimetype]
        return by_mimetype if by_mimetype

        by_filename = guess_by_filename(info[:filename]) if info[:filename]
        return by_filename if by_filename

        by_source = guess_by_source(info[:source]) if info[:source]
        return by_source if by_source

        # guessing failed, just parse it as text
        return Lexers::Text
      end

      def guess_by_mimetype(mt)
        registry.values.detect do |lexer|
          lexer.mimetypes.include? mt
        end
      end

      def guess_by_filename(fname)
        fname = File.basename(fname)
        registry.values.detect do |lexer|
          lexer.filenames.any? do |pattern|
            File.fnmatch?(pattern, fname, File::FNM_DOTMATCH)
          end
        end
      end

      def guess_by_source(source)
        assert_utf8!(source)

        source = TextAnalyzer.new(source)

        best_result = 0
        best_match = nil
        registry.values.each do |lexer|
          result = lexer.analyze_text(source) || 0
          return lexer if result == 1

          if result > best_result
            best_match = lexer
            best_result = result
          end
        end

        best_match
      end

      # @private
      def register(name, lexer)
        registry[name.to_s] = lexer
      end

      # Used to specify or get the canonical name of this lexer class.
      #
      # @example
      #   class MyLexer < Lexer
      #     tag 'foo'
      #   end
      #
      #   MyLexer.tag # => 'foo'
      #
      #   Lexer.find('foo') # => MyLexer
      def tag(t=nil)
        return @tag if t.nil?

        @tag = t.to_s
        Lexer.register(@tag, self)
      end

      # Used to specify alternate names this lexer class may be found by.
      #
      # @example
      #   class Erb < Lexer
      #     tag 'erb'
      #     aliases 'eruby', 'rhtml'
      #   end
      #
      #   Lexer.find('eruby') # => Erb
      def aliases(*args)
        args.map!(&:to_s)
        args.each { |arg| Lexer.register(arg, self) }
        (@aliases ||= []).concat(args)
      end

      # Specify a list of filename globs associated with this lexer.
      #
      # @example
      #   class Ruby < Lexer
      #     filenames '*.rb', '*.ruby', 'Gemfile', 'Rakefile'
      #   end
      def filenames(*fnames)
        (@filenames ||= []).concat(fnames)
      end

      # Specify a list of mimetypes associated with this lexer.
      #
      # @example
      #   class Html < Lexer
      #     mimetypes 'text/html', 'application/xhtml+xml'
      #   end
      def mimetypes(*mts)
        (@mimetypes ||= []).concat(mts)
      end

      # @private
      def assert_utf8!(str)
        return if %w(US-ASCII UTF-8).include? str.encoding.name
        raise EncodingError.new(
          "Bad encoding: #{str.encoding.names.join(',')}. " +
          "Please convert your string to UTF-8."
        )
      end

    private
      def registry
        @registry ||= {}
      end
    end

    # -*- instance methods -*- #

    # Create a new lexer with the given options.  Individual lexers may
    # specify extra options.  The only current globally accepted option
    # is `:debug`.
    #
    # @option opts :debug
    #   Prints debug information to stdout.  The particular info depends
    #   on the lexer in question.  In regex lexers, this will log the
    #   state stack at the beginning of each step, along with each regex
    #   tried and each stream consumed.  Try it, it's pretty useful.
    def initialize(opts={})
      options(opts)
    end

    # get and/or specify the options for this lexer.
    def options(o={})
      (@options ||= {}).merge!(o)

      self.class.default_options.merge(@options)
    end

    # get or specify one option for this lexer
    def option(k, v=:absent)
      if v == :absent
        options[k]
      else
        options({ k => v })
      end
    end

    # Leave a debug message if the `:debug` option is set.  The message
    # is given as a block because some debug messages contain calculated
    # information that is unnecessary for lexing in the real world.
    #
    # @example
    #   debug { "hello, world!" }
    def debug(&b)
      puts(b.call) if option :debug
    end

    # @abstract
    #
    # Called after each lex is finished.  The default implementation
    # is a noop.
    def reset!
    end

    # Given a string, yield [token, chunk] pairs.  If no block is given,
    # an enumerator is returned.
    #
    # @option opts :continue
    #   Continue the lex from the previous state (i.e. don't call #reset!)
    def lex(string, opts={}, &b)
      return enum_for(:lex, string) unless block_given?

      Lexer.assert_utf8!(string)

      reset! unless opts[:continue]

      # consolidate consecutive tokens of the same type
      last_token = nil
      last_val = nil
      stream_tokens(StringScanner.new(string)) do |tok, val|
        next if val.empty?

        if tok == last_token
          last_val << val
          next
        end

        b.call(last_token, last_val) if last_token
        last_token = tok
        last_val = val
      end

      b.call(last_token, last_val) if last_token
    end

    # delegated to {Lexer.tag}
    def tag
      self.class.tag
    end

    # @abstract
    #
    # Yield `[token, chunk]` pairs, given a prepared input stream.  This
    # must be implemented.
    #
    # @param [StringScanner] stream
    #   the stream
    def stream_tokens(stream, &b)
      raise 'abstract'
    end

    # @abstract
    #
    # Return a number between 0 and 1 indicating the likelihood that
    # the text given should be lexed with this lexer.  The default
    # implementation returns 0.
    #
    # @param [TextAnalyzer] text
    #   the text to be analyzed, with a couple of handy methods on it,
    #   like {TextAnalyzer#shebang?} and {TextAnalyzer#doctype?}
    def self.analyze_text(text)
      0
    end
  end
end
module Rouge
  module Lexers
    class C < RegexLexer
      tag 'c'
      filenames '*.c', '*.h', '*.idc'
      mimetypes 'text/x-chdr', 'text/x-csrc'

      desc "The C programming language"

      # optional comment or whitespace
      ws = %r((?:\s|//.*?\n|/[*].*?[*]/)+)
      id = /[a-zA-Z_][a-zA-Z0-9_]*/

      keywords = %w(
        auto break case const continue default do else enum extern
        for goto if register restricted return sizeof static struct
        switch typedef union volatile virtual while
      )

      keywords_type = %w(int long float short double char unsigned signed void)

      __reserved = %w(
        asm int8 based except int16 stdcall cdecl fastcall int32
        declspec finally int61 try leave
      )

      state :whitespace do
        rule /^#if\s+0\b/, 'Comment.Preproc', :if_0
        rule /^#/, 'Comment.Preproc', :macro
        rule /^#{ws}#if\s+0\b/, 'Comment.Preproc', :if_0
        rule /^#{ws}#/, 'Comment.Preproc', :macro
        rule /^(\s*)(#{id}:(?!:))/ do
          group 'Text'
          group 'Name.Label'
        end

        rule /\s+/m, 'Text'
        rule /\\\n/, 'Text' # line continuation
        rule %r(//(\n|(.|\n)*?[^\\]\n)), 'Comment.Single'
        rule %r(/(\\\n)?[*](.|\n)*?[*](\\\n)?/), 'Comment.Multiline'
      end

      state :statements do
        rule /L?"/, 'Literal.String', :string
        rule %r(L?'(\\.|\\[0-7]{1,3}|\\x[a-f0-9]{1,2}|[^\\'\n])')i, 'Literal.String.Char'
        rule %r((\d+\.\d*|\.\d+|\d+)[e][+-]?\d+[lu]*)i, 'Literal.Number.Float'
        rule /0x[0-9a-f]+[lu]*/i, 'Literal.Number.Hex'
        rule /0[0-7]+[lu]*/i, 'Literal.Number.Oct'
        rule /\d+[lu]*/i, 'Literal.Number.Integer'
        rule %r(\*/), 'Error'
        rule %r([~!%^&*+=\|?:<>/-]), 'Operator'
        rule /[()\[\],.]/, 'Punctuation'
        rule /\bcase\b/, 'Keyword', :case
        rule /(?:#{keywords.join('|')})\b/, 'Keyword'
        rule /(?:#{keywords_type.join('|')})\b/, 'Keyword.Type'
        rule /(?:_{0,2}inline|naked|restrict|thread|typename)\b/, 'Keyword.Reserved'
        rule /__(?:#{__reserved.join('|')})\b/, 'Keyword.Reserved'
        rule /(?:true|false|NULL)\b/, 'Name.Builtin'
        rule id, 'Name'
        rule /\s+/m, 'Text'
      end

      state :case do
        rule /:/, 'Punctuation', :pop!
        mixin :statements
      end

      state :root do
        mixin :whitespace

        # functions
        rule %r(
          ([\w*\s]+?[\s*]) # return arguments
          (#{id})          # function name
          (\s*\([^;]*?\))  # signature
          (#{ws})({)         # open brace
        )mx do |m|
          # TODO: do this better.
          delegate C, m[1]
          token 'Name.Function', m[2]
          delegate C, m[3]
          delegate C, m[4]
          token 'Punctuation', m[5]
          push :function
        end

        # function declarations
        rule %r(
          ([\w*\s]+?[\s*]) # return arguments
          (#{id})          # function name
          (\s*\([^;]*?\))  # signature
          (#{ws})(;)       # semicolon
        )mx do |m|
          # TODO: do this better.
          delegate C, m[1]
          token 'Name.Function'
          delegate C, m[3]
          delegate C, m[4]
          token 'Punctuation'
          push :statement
        end

        rule(//) { push :statement }
      end

      state :statement do
        rule /;/, 'Punctuation', :pop!
        mixin :whitespace
        mixin :statements
        rule /[{}]/, 'Punctuation'
      end

      state :function do
        mixin :whitespace
        mixin :statements
        rule /;/, 'Punctuation'
        rule /{/, 'Punctuation', :function
        rule /}/, 'Punctuation', :pop!
      end

      state :string do
        rule /"/, 'Literal.String', :pop!
        rule /\\([\\abfnrtv"']|x[a-fA-F0-9]{2,4}|[0-7]{1,3})/, 'Literal.String.Escape'
        rule /[^\\"\n]+/, 'Literal.String'
        rule /\\\n/, 'Literal.String'
        rule /\\/, 'Literal.String' # stray backslash
      end

      state :macro do
        rule %r([^/\n]+), 'Comment.Preproc'
        rule %r(/[*].*?[*]/)m, 'Comment.Multiliine'
        rule %r(//.*$), 'Comment.Single'
        rule %r(/), 'Comment.Preproc'
        rule /(?<=\\)\n/, 'Comment.Preproc'
        rule /\n/, 'Comment.Preproc', :pop!
      end

      state :if_0 do
        rule /^\s*#if.*?(?<!\\)\n/, 'Comment.Preproc', :if_0
        rule /^\s*#el(?:se|if).*\n/, 'Comment.Preproc', :pop!
        rule /^\s*#endif.*?(?<!\\)\n/, 'Comment.Preproc', :pop!
        rule /.*?\n/, 'Comment'
      end
    end
  end
end
module Rouge
  module Lexers
    class Clojure < RegexLexer
      desc "The Clojure programming language (clojure.org)"

      tag 'clojure'
      aliases 'clj'

      filenames '*.clj'

      mimetypes 'text/x-clojure', 'application/x-clojure'

      def self.keywords
        @keywords ||= Set.new %w(
          fn def defn defmacro defmethod defmulti defn- defstruct if
          cond let for
        )
      end

      def self.builtins
        @builtins ||= Set.new %w(
          . ..  * + - -> / < <= = == > >= accessor agent agent-errors
          aget alength all-ns alter and append-child apply array-map
          aset aset-boolean aset-byte aset-char aset-double aset-float
          aset-int aset-long aset-short assert assoc await await-for bean
          binding bit-and bit-not bit-or bit-shift-left bit-shift-right
          bit-xor boolean branch?  butlast byte cast char children
          class clear-agent-errors comment commute comp comparator
          complement concat conj cons constantly construct-proxy
          contains? count create-ns create-struct cycle dec  deref
          difference disj dissoc distinct doall doc dorun doseq dosync
          dotimes doto double down drop drop-while edit end? ensure eval
          every? false? ffirst file-seq filter find find-doc find-ns
          find-var first float flush fnseq frest gensym get-proxy-class
          get hash-map hash-set identical? identity if-let import in-ns
          inc index insert-child insert-left insert-right inspect-table
          inspect-tree instance? int interleave intersection into
          into-array iterate join key keys keyword keyword? last lazy-cat
          lazy-cons left lefts line-seq list* list load load-file locking
          long loop macroexpand macroexpand-1 make-array make-node map
          map-invert map? mapcat max max-key memfn merge merge-with meta
          min min-key name namespace neg? new newline next nil? node not
          not-any? not-every? not= ns-imports ns-interns ns-map ns-name
          ns-publics ns-refers ns-resolve ns-unmap nth nthrest or parse
          partial path peek pop pos? pr pr-str print print-str println
          println-str prn prn-str project proxy proxy-mappings quot
          rand rand-int range re-find re-groups re-matcher re-matches
          re-pattern re-seq read read-line reduce ref ref-set refer rem
          remove remove-method remove-ns rename rename-keys repeat replace
          replicate resolve rest resultset-seq reverse rfirst right
          rights root rrest rseq second select select-keys send send-off
          seq seq-zip seq? set short slurp some sort sort-by sorted-map
          sorted-map-by sorted-set special-symbol? split-at split-with
          str string?  struct struct-map subs subvec symbol symbol?
          sync take take-nth take-while test time to-array to-array-2d
          tree-seq true? union up update-proxy val vals var-get var-set
          var? vector vector-zip vector? when when-first when-let
          when-not with-local-vars with-meta with-open with-out-str
          xml-seq xml-zip zero? zipmap zipper'
        )
      end

      identifier = %r([\w!$%*+,<=>?/.-]+)

      def name_token(name)
        return 'Keyword' if self.class.keywords.include?(name)
        return 'Name.Builtin' if self.class.builtins.include?(name)
        nil
      end

      state :root do
        rule /;.*?\n/, 'Comment.Single'
        rule /\s+/m, 'Text.Whitespace'

        rule /-?\d+\.\d+/, 'Literal.Number.Float'
        rule /-?\d+/, 'Literal.Number.Integer'
        rule /0x-?[0-9a-fA-F]+/, 'Literal.Number.Hex'

        rule /"(\\.|[^"])*"/, 'Literal.String'
        rule /'#{identifier}/, 'Literal.String.Symbol'
        rule /\\(.|[a-z]+)/i, 'Literal.String.Char'

        rule /:#{identifier}/, 'Name.Constant'

        rule /~@|[`\'#^~&]/, 'Operator'

        rule /(\()(\s*)(#{identifier})/m do |m|
          token 'Punctuation', m[1]
          token 'Text.Whitespace', m[2]
          token(name_token(m[3]) || 'Name.Function', m[3])
        end

        rule identifier do |m|
          token name_token(m[0]) || 'Name.Variable'
        end

        # vectors
        rule /[\[\]]/, 'Punctuation'

        # maps
        rule /[{}]/, 'Punctuation'

        # parentheses
        rule /[()]/, 'Punctuation'
      end
    end
  end
end
module Rouge
  module Lexers
    class Coffeescript < RegexLexer
      tag 'coffeescript'
      aliases 'coffee', 'coffee-script'
      filenames '*.coffee', 'Cakefile'
      mimetypes 'text/coffeescript'

      desc 'The Coffeescript programming language (coffeescript.org)'

      def self.analyze_text(text)
        return 1 if text.shebang? 'coffee'
      end

      def self.keywords
        @keywords ||= Set.new %w(
          for in of while break return continue switch when then if else
          throw try catch finally new delete typeof instanceof super
          extends this class by
        )
      end

      def self.constants
        @constants ||= Set.new %w(
          true false yes no on off null NaN Infinity undefined
        )
      end

      def self.builtins
        @builtins ||= Set.new %w(
          Array Boolean Date Error Function Math netscape Number Object
          Packages RegExp String sun decodeURI decodeURIComponent
          encodeURI encodeURIComponent eval isFinite isNaN parseFloat
          parseInt document window
        )
      end

      id = /[$a-zA-Z_][a-zA-Z0-9_]*/
      lval = /@?#{id}([.]#{id})*/

      state :comments_and_whitespace do
        rule /\s+/m, 'Text'
        rule /###.*?###/m, 'Comment.Multiline'
        rule /#.*?\n/, 'Comment.Single'
      end

      state :multiline_regex do
        mixin :comments_and_whitespace
        rule %r(///([gim]+\b|\B)), 'Literal.String.Regex', :pop!
        rule %r(/), 'Literal.String.Regex'
        rule %r([^/#]+), 'Literal.String.Regex'
      end

      state :slash_starts_regex do
        mixin :comments_and_whitespace
        rule %r(///) do
          token 'Literal.String.Regex'
          pop!; push :multiline_regex
        end

        rule %r(
          /(\\.|[^\[/\\\n]|\[(\\.|[^\]\\\n])*\])+/ # a regex
          ([gim]+\b|\B)
        )x, 'Literal.String.Regex', :pop!

        rule(//) { pop! }
      end

      state :root do
        rule(%r(^(?=\s|/|<!--))) { push :slash_starts_regex }
        mixin :comments_and_whitespace
        rule %r(
          [+][+]|--|~|&&|\band\b|\bor\b|\bis\b|\bisnt\b|\bnot\b|[?]|:|=|
          [|][|]|\\(?=\n)|(<<|>>>?|==?|!=?|[-<>+*`%&|^/])=?
        )x, 'Operator', :slash_starts_regex

        rule /[-=]>/, 'Name.Function'

        rule /(@)([ \t]*)(#{id})/ do
          group 'Name.Variable.Instance'; group 'Text'
          group 'Name.Attribute'
          push :slash_starts_regex
        end

        rule /([.])([ \t]*)(#{id})/ do
          group 'Punctuation'; group 'Text'
          group 'Name.Attribute'
          push :slash_starts_regex
        end

        rule /#{id}(?=\s*:)/, 'Name.Attribute', :slash_starts_regex

        rule /#{id}/, 'Name.Other', :slash_starts_regex

        rule /[{(\[;,]/, 'Punctuation', :slash_starts_regex
        rule /[})\].]/, 'Punctuation'

        rule /\d+[.]\d+([eE]\d+)?[fd]?/, 'Literal.Number.Float'
        rule /0x[0-9a-fA-F]+/, 'Literal.Number.Hex'
        rule /\d+/, 'Literal.Number.Integer'
        rule /"""/, 'Literal.String', :tdqs
        rule /'''/, 'Literal.String', :tsqs
        rule /"/, 'Literal.String', :dqs
        rule /'/, 'Literal.String', :sqs
      end

      state :strings do
        # all coffeescript strings are multi-line
        rule /[^#\\'"]+/m, 'Literal.String'

        rule /\\./, 'Literal.String.Escape'
        rule /#/, 'Literal.String'
      end

      state :double_strings do
        rule /'/, 'Literal.String'
        mixin :has_interpolation
        mixin :strings
      end

      state :single_strings do
        rule /"/, 'Literal.String'
        mixin :strings
      end

      state :interpolation do
        rule /}/, 'Literal.String.Interpol', :pop!
        mixin :root
      end

      state :has_interpolation do
        rule /[#][{]/, 'Literal.String.Interpol', :interpolation
      end

      state :dqs do
        rule /"/, 'Literal.String', :pop!
        mixin :double_strings
      end

      state :tdqs do
        rule /"""/, 'Literal.String', :pop!
        rule /"/, 'Literal.String'
        mixin :double_strings
      end

      state :sqs do
        rule /'/, 'Literal.String', :pop!
        mixin :single_strings
      end

      state :tsqs do
        rule /'''/, 'Literal.String', :pop!
        rule /'/, 'Literal.String'
        mixin :single_strings
      end

      postprocess 'Name' do |tok, val|
        if tok.name == 'Name.Attribute'
          # pass. leave attributes alone.
        elsif self.class.keywords.include? val
          tok = 'Keyword'
        elsif self.class.constants.include? val
          tok = 'Name.Constant'
        elsif self.class.builtins.include? val
          tok = 'Name.Builtin'
        end

        token tok, val
      end
    end
  end
end
# stdlib
require 'set'

module Rouge
  module Lexers
    class CommonLisp < RegexLexer
      desc "The Common Lisp variant of Lisp (common-lisp.net)"
      tag 'common_lisp'
      aliases 'cl', 'common-lisp'

      filenames '*.cl', '*.lisp', '*.el' # used for Elisp too
      mimetypes 'text/x-common-lisp'

      # 638 functions
      BUILTIN_FUNCTIONS = Set.new %w(
        < <= = > >= - / /= * + 1- 1+ abort abs acons acos acosh add-method
        adjoin adjustable-array-p adjust-array allocate-instance
        alpha-char-p alphanumericp append apply apropos apropos-list
        aref arithmetic-error-operands arithmetic-error-operation
        array-dimension array-dimensions array-displacement
        array-element-type array-has-fill-pointer-p array-in-bounds-p
        arrayp array-rank array-row-major-index array-total-size
        ash asin asinh assoc assoc-if assoc-if-not atan atanh atom
        bit bit-and bit-andc1 bit-andc2 bit-eqv bit-ior bit-nand
        bit-nor bit-not bit-orc1 bit-orc2 bit-vector-p bit-xor boole
        both-case-p boundp break broadcast-stream-streams butlast
        byte byte-position byte-size caaaar caaadr caaar caadar
        caaddr caadr caar cadaar cadadr cadar caddar cadddr caddr
        cadr call-next-method car cdaaar cdaadr cdaar cdadar cdaddr
        cdadr cdar cddaar cddadr cddar cdddar cddddr cdddr cddr cdr
        ceiling cell-error-name cerror change-class char char< char<=
        char= char> char>= char/= character characterp char-code
        char-downcase char-equal char-greaterp char-int char-lessp
        char-name char-not-equal char-not-greaterp char-not-lessp
        char-upcase cis class-name class-of clear-input clear-output
        close clrhash code-char coerce compile compiled-function-p
        compile-file compile-file-pathname compiler-macro-function
        complement complex complexp compute-applicable-methods
        compute-restarts concatenate concatenated-stream-streams conjugate
        cons consp constantly constantp continue copy-alist copy-list
        copy-pprint-dispatch copy-readtable copy-seq copy-structure
        copy-symbol copy-tree cos cosh count count-if count-if-not
        decode-float decode-universal-time delete delete-duplicates
        delete-file delete-if delete-if-not delete-package denominator
        deposit-field describe describe-object digit-char digit-char-p
        directory directory-namestring disassemble documentation dpb
        dribble echo-stream-input-stream echo-stream-output-stream
        ed eighth elt encode-universal-time endp enough-namestring
        ensure-directories-exist ensure-generic-function eq
        eql equal equalp error eval evenp every exp export expt
        fboundp fceiling fdefinition ffloor fifth file-author
        file-error-pathname file-length file-namestring file-position
        file-string-length file-write-date fill fill-pointer find
        find-all-symbols find-class find-if find-if-not find-method
        find-package find-restart find-symbol finish-output first
        float float-digits floatp float-precision float-radix
        float-sign floor fmakunbound force-output format fourth
        fresh-line fround ftruncate funcall function-keywords
        function-lambda-expression functionp gcd gensym gentemp get
        get-decoded-time get-dispatch-macro-character getf gethash
        get-internal-real-time get-internal-run-time get-macro-character
        get-output-stream-string get-properties get-setf-expansion
        get-universal-time graphic-char-p hash-table-count hash-table-p
        hash-table-rehash-size hash-table-rehash-threshold
        hash-table-size hash-table-test host-namestring identity
        imagpart import initialize-instance input-stream-p inspect
        integer-decode-float integer-length integerp interactive-stream-p
        intern intersection invalid-method-error invoke-debugger
        invoke-restart invoke-restart-interactively isqrt keywordp
        last lcm ldb ldb-test ldiff length lisp-implementation-type
        lisp-implementation-version list list* list-all-packages listen
        list-length listp load load-logical-pathname-translations
        log logand logandc1 logandc2 logbitp logcount logeqv
        logical-pathname logical-pathname-translations logior
        lognand lognor lognot logorc1 logorc2 logtest logxor
        long-site-name lower-case-p machine-instance machine-type
        machine-version macroexpand macroexpand-1 macro-function
        make-array make-broadcast-stream make-concatenated-stream
        make-condition make-dispatch-macro-character make-echo-stream
        make-hash-table make-instance make-instances-obsolete make-list
        make-load-form make-load-form-saving-slots make-package
        make-pathname make-random-state make-sequence make-string
        make-string-input-stream make-string-output-stream make-symbol
        make-synonym-stream make-two-way-stream makunbound map mapc
        mapcan mapcar mapcon maphash map-into mapl maplist mask-field
        max member member-if member-if-not merge merge-pathnames
        method-combination-error method-qualifiers min minusp mismatch mod
        muffle-warning name-char namestring nbutlast nconc next-method-p
        nintersection ninth no-applicable-method no-next-method not notany
        notevery nreconc nreverse nset-difference nset-exclusive-or
        nstring-capitalize nstring-downcase nstring-upcase nsublis
        nsubst nsubst-if nsubst-if-not nsubstitute nsubstitute-if
        nsubstitute-if-not nth nthcdr null numberp numerator nunion
        oddp open open-stream-p output-stream-p package-error-package
        package-name package-nicknames packagep package-shadowing-symbols
        package-used-by-list package-use-list pairlis parse-integer
        parse-namestring pathname pathname-device pathname-directory
        pathname-host pathname-match-p pathname-name pathnamep
        pathname-type pathname-version peek-char phase plusp
        position position-if position-if-not pprint pprint-dispatch
        pprint-fill pprint-indent pprint-linear pprint-newline pprint-tab
        pprint-tabular prin1 prin1-to-string princ princ-to-string print
        print-object probe-file proclaim provide random random-state-p
        rassoc rassoc-if rassoc-if-not rational rationalize rationalp
        read read-byte read-char read-char-no-hang read-delimited-list
        read-from-string read-line read-preserving-whitespace
        read-sequence readtable-case readtablep realp realpart
        reduce reinitialize-instance rem remhash remove
        remove-duplicates remove-if remove-if-not remove-method
        remprop rename-file rename-package replace require rest
        restart-name revappend reverse room round row-major-aref
        rplaca rplacd sbit scale-float schar search second set
        set-difference set-dispatch-macro-character set-exclusive-or
        set-macro-character set-pprint-dispatch set-syntax-from-char
        seventh shadow shadowing-import shared-initialize
        short-site-name signal signum simple-bit-vector-p
        simple-condition-format-arguments simple-condition-format-control
        simple-string-p simple-vector-p sin sinh sixth sleep slot-boundp
        slot-exists-p slot-makunbound slot-missing slot-unbound slot-value
        software-type software-version some sort special-operator-p
        sqrt stable-sort standard-char-p store-value stream-element-type
        stream-error-stream stream-external-format streamp string string<
        string<= string= string> string>= string/= string-capitalize
        string-downcase string-equal string-greaterp string-left-trim
        string-lessp string-not-equal string-not-greaterp string-not-lessp
        stringp string-right-trim string-trim string-upcase sublis subseq
        subsetp subst subst-if subst-if-not substitute substitute-if
        substitute-if-not subtypepsvref sxhash symbol-function
        symbol-name symbolp symbol-package symbol-plist symbol-value
        synonym-stream-symbol syntax: tailp tan tanh tenth terpri third
        translate-logical-pathname translate-pathname tree-equal truename
        truncate two-way-stream-input-stream two-way-stream-output-stream
        type-error-datum type-error-expected-type type-of
        typep unbound-slot-instance unexport unintern union
        unread-char unuse-package update-instance-for-different-class
        update-instance-for-redefined-class upgraded-array-element-type
        upgraded-complex-part-type upper-case-p use-package
        user-homedir-pathname use-value values values-list vector vectorp
        vector-pop vector-push vector-push-extend warn wild-pathname-p
        write write-byte write-char write-line write-sequence write-string
        write-to-string yes-or-no-p y-or-n-p zerop
      ).freeze

      SPECIAL_FORMS = Set.new %w(
        block catch declare eval-when flet function go if labels lambda
        let let* load-time-value locally macrolet multiple-value-call
        multiple-value-prog1 progn progv quote return-from setq
        symbol-macrolet tagbody the throw unwind-protect
      )

      MACROS = Set.new %w(
        and assert call-method case ccase check-type cond ctypecase decf
        declaim defclass defconstant defgeneric define-compiler-macro
        define-condition define-method-combination define-modify-macro
        define-setf-expander define-symbol-macro defmacro defmethod
        defpackage defparameter defsetf defstruct deftype defun defvar
        destructuring-bind do do* do-all-symbols do-external-symbols
        dolist do-symbols dotimes ecase etypecase formatter
        handler-bind handler-case ignore-errors incf in-package
        lambda loop loop-finish make-method multiple-value-bind
        multiple-value-list multiple-value-setq nth-value or pop
        pprint-exit-if-list-exhausted pprint-logical-block pprint-pop
        print-unreadable-object prog prog* prog1 prog2 psetf psetq
        push pushnew remf restart-bind restart-case return rotatef
        setf shiftf step time trace typecase unless untrace when
        with-accessors with-compilation-unit with-condition-restarts
        with-hash-table-iterator with-input-from-string with-open-file
        with-open-stream with-output-to-string with-package-iterator
        with-simple-restart with-slots with-standard-io-syntax
      )

      LAMBDA_LIST_KEYWORDS = Set.new %w(
        &allow-other-keys &aux &body &environment &key &optional &rest
        &whole
      )

      DECLARATIONS = Set.new %w(
        dynamic-extent ignore optimize ftype inline special ignorable
        notinline type
      )

      BUILTIN_TYPES = Set.new %w(
        atom boolean base-char base-string bignum bit compiled-function
        extended-char fixnum keyword nil signed-byte short-float
        single-float double-float long-float simple-array
        simple-base-string simple-bit-vector simple-string simple-vector
        standard-char unsigned-byte

        arithmetic-error cell-error condition control-error
        division-by-zero end-of-file error file-error
        floating-point-inexact floating-point-overflow
        floating-point-underflow floating-point-invalid-operation
        parse-error package-error print-not-readable program-error
        reader-error serious-condition simple-condition simple-error
        simple-type-error simple-warning stream-error storage-condition
        style-warning type-error unbound-variable unbound-slot
        undefined-function warning
      )

      BUILTIN_CLASSES = Set.new %w(
        array broadcast-stream bit-vector built-in-class character
        class complex concatenated-stream cons echo-stream file-stream
        float function generic-function hash-table integer list
        logical-pathname method-combination method null number package
        pathname ratio rational readtable real random-state restart
        sequence standard-class standard-generic-function standard-method
        standard-object string-stream stream string structure-class
        structure-object symbol synonym-stream t two-way-stream vector
      )

      postprocess 'Name.Variable' do |tok, val|
        tok = if BUILTIN_FUNCTIONS.include? val
          'Name.Builtin'
        elsif SPECIAL_FORMS.include? val
          'Keyword'
        elsif MACROS.include? val
          'Name.Builtin'
        elsif LAMBDA_LIST_KEYWORDS.include? val
          'Keyword'
        elsif DECLARATIONS.include? val
          'Keyword'
        elsif BUILTIN_TYPES.include? val
          'Keyword.Type'
        elsif BUILTIN_CLASSES.include? val
          'Name.Class'
        else
          'Name.Variable'
        end

        token tok, val
      end

      nonmacro = /\\.|[a-zA-Z0-9!$%&*+-\/<=>?@\[\]^_{}~]/
      constituent = /#{nonmacro}|[#.:]/
      terminated = /(?=[ "'()\n,;`])/ # whitespace or terminating macro chars
      symbol = /(\|[^\|]+\||#{nonmacro}#{constituent}*)/

      state :root do
        rule /\s+/m, 'Text'
        rule /;.*$/, 'Comment.Single'
        rule /#\|/, 'Comment.Multiline', :multiline_comment

        # encoding comment
        rule /#\d*Y.*$/, 'Comment.Special'
        rule /"(\\.|[^"\\])*"/, 'Literal.String'

        rule /[:']#{symbol}/, 'Literal.String.Symbol'
        rule /['`]/, 'Operator'

        # numbers
        rule /[-+]?\d+\.?#{terminated}/, 'Literal.Number.Integer'
        rule %r([-+]?\d+/\d+#{terminated}), 'Literal.Number.Integer'
        rule %r(
          [-+]?
          (\d*\.\d+([defls][-+]?\d+)?
          |\d+(\.\d*)?[defls][-+]?\d+)
          #{terminated}
        )x, 'Literal.Number.Float'

        # sharpsign strings and characters
        rule /#\\.#{terminated}/, 'Literal.String.Char'
        rule /#\\#{symbol}/, 'Literal.String.Char'

        rule /#\(/, 'Operator', :root

        # bitstring
        rule /#\d*\*[01]*/, 'Literal.Other'

        # uninterned symbol
        rule /#:#{symbol}/, 'Literal.String.Symbol'

        # read-time and load-time evaluation
        rule /#[.,]/, 'Operator'

        # function shorthand
        rule /#'/, 'Name.Function'

        # binary rational
        rule /#b[+-]?[01]+(\/[01]+)?/i, 'Literal.Number'

        # octal rational
        rule /#o[+-]?[0-7]+(\/[0-7]+)?/i, 'Literal.Number.Oct'

        # hex rational
        rule /#x[+-]?[0-9a-f]+(\/[0-9a-f]+)?/i, 'Literal.Number'

        # complex
        rule /(#c)(\()/i do
          group 'Literal.Number'
          group 'Punctuation'
          push :root
        end

        # arrays and structures
        rule /(#(?:\d+a|s))(\()/i do
          group 'Literal.Other'
          group 'Punctuation'
          push :root
        end

        # path
        rule /#p?"(\\.|[^"])*"/i

        # reference
        rule /#\d+[=#]/, 'Operator'

        # read-time comment
        rule /#+nil#{terminated}\s*\(/, 'Comment.Preproc', :commented_form

        # read-time conditional
        rule /#[+-]/, 'Operator'

        # special operators that should have been parsed already
        rule /(,@|,|\.)/, 'Operator'

        # special constants
        rule /(t|nil)#{terminated}/, 'Name.Constant'

        # functions and variables
        # note that these get filtered through in stream_tokens
        rule /\*#{symbol}\*/, 'Name.Variable.Global'
        rule symbol, 'Name.Variable'

        rule /\(/, 'Punctuation', :root
        rule /\)/, 'Punctuation' do
          if stack.empty?
            token 'Error'
          else
            token 'Punctuation'
            pop!
          end
        end
      end

      state :multiline_comment do
        rule /#\|/, 'Comment.Multiline', :multiline_comment
        rule /\|#/, 'Comment.Multiline', :pop!
        rule /[^\|#]+/, 'Comment.Multiline'
        rule /[\|#]/, 'Comment.Multiline'
      end

      state :commented_form do
        rule /\(/, 'Comment.Preproc', :commented_form
        rule /\)/, 'Comment.Preproc', :pop!
      end
    end
  end
end
module Rouge
  module Lexers
    class Cpp < RegexLexer
      desc "The C++ programming language"

      tag 'cpp'
      aliases 'c++'
      # the many varied filenames of c++ source files...
      filenames '*.cpp', '*.hpp',
                '*.c++', '*.h++',
                '*.cc',  '*.hh',
                '*.cxx', '*.hxx'
      mimetypes 'text/x-c++hdr', 'text/x-c++src'

      keywords = %w(
        asm auto break case catch const const_cast continue
        default delete do dynamic_cast else enum explicit export
        extern for friend goto if mutable namespace new operator
        private protected public register reinterpret_cast return
        restrict sizeof static static_cast struct switch template
        this throw throws try typedef typeid typename union using
        volatile virtual while
      )

      keywords_type = %w(
        bool int long float short double char unsigned signed void wchar_t
      )

      __reserved = %w(
        asm int8 based except int16 stdcall cdecl fastcall int32 declspec
        finally int64 try leave wchar_t w64 virtual_inheritance uuidof
        unaligned super single_inheritance raise noop multiple_inheritance
        m128i m128d m128 m64 interface identifier forceinline event assume
      )

      # optional comments or whitespace
      ws = %r((?:\s|//.*?\n|/[*].*?[*]/)+)
      id = /[a-zA-Z_][a-zA-Z0-9]*/

      state :whitespace do
        rule /^#if\s+0/, 'Comment.Preproc', :if_0
        rule /^#/, 'Comment.Preproc', :macro
        rule /^#{ws}#if\s+0\b/, 'Comment.Preproc', :if_0
        rule /^#{ws}#/, 'Comment.Preproc', :macro
        rule /\s+/m, 'Text'
        rule /\\\n/, 'Text'
        rule %r(/(\\\n)?/(\n|(.|\n)*?[^\\]\n)), 'Comment.Single'
        rule %r(/(\\\n)?[*](.|\n)*?[*](\\\n)?/), 'Comment.Multiline'
      end

      state :root do
        mixin :whitespace

        rule /L?"/, 'Literal.String', :string
        rule %r(L?'(\\.|\\[0-7]{1,3}|\\x[a-f0-9]{1,2}|[^\\'\n])')i, 'Literal.String.Char'
        rule %r((\d+\.\d*|\.\d+|\d+)[e][+-]?\d+[lu]*)i, 'Literal.Number.Float'
        rule /0x[0-9a-f]+[lu]*/i, 'Literal.Number.Hex'
        rule /0[0-7]+[lu]*/i, 'Literal.Number.Oct'
        rule /\d+[lu]*/i, 'Literal.Number.Integer'
        rule %r(\*/), 'Error'
        rule %r([~!%^&*+=\|?:<>/-]), 'Operator'
        rule /[()\[\],.;{}]/, 'Punctuation'

        rule /(?:#{keywords.join('|')})\b/, 'Keyword'
        rule /class\b/, 'Keyword', :classname
        rule /(?:#{keywords_type.join('|')})\b/, 'Keyword.Type'
        rule /(?:_{0,2}inline|naked|thread)\b/, 'Keyword.Reserved'
        rule /__(?:#{__reserved.join('|')})\b/, 'Keyoword.Reserved'
        # Offload C++ extensions, http://offload.codeplay.com/
        rule /(?:__offload|__blockingoffload|__outer)\b/, 'Keyword.Pseudo'

        rule /(true|false)\b/, 'Keyword.Constant'
        rule /NULL\b/, 'Name.Builtin'
        rule /#{id}:(?!:)/, 'Name.Label'
        rule id, 'Name'
      end

      state :classname do
        rule id, 'Name.Class', :pop!

        # template specification
        rule /\s*(?=>)/m, 'Text', :pop!
        mixin :whitespace
      end

      state :string do
        rule /"/, 'Literal.String', :pop!
        rule /\\([\\abfnrtv"']|x[a-fA-F0-9]{2,4}|[0-7]{1,3})/, 'Literal.String.Escape'
        rule /[^\\"\n]+/, 'Literal.String'
        rule /\\\n/, 'Literal.String'
        rule /\\/, 'Literal.String' # stray backslash
      end

      state :macro do
        rule %r([^/\n]+), 'Comment.Preproc'
        rule %r(/[*].*?[*]/)m, 'Comment.Multiliine'
        rule %r(//.*$), 'Comment.Single'
        rule %r(/), 'Comment.Preproc'
        rule /(?<=\\)\n/, 'Comment.Preproc'
        rule /\n/, 'Comment.Preproc', :pop!
      end

      state :if_0 do
        rule /^\s*#if.*?(?<!\\)\n/, 'Comment.Preproc', :if_0
        rule /^\s*#el(?:se|if).*\n/, 'Comment.Preproc', :pop!
        rule /^\s*#endif.*?(?<!\\)\n/, 'Comment.Preproc', :pop!
        rule /.*?\n/, 'Comment'
      end
    end
  end
end
module Rouge
  module Lexers
    class CSS < RegexLexer
      desc "Cascading Style Sheets, used to style web pages"

      tag 'css'
      filenames '*.css'
      mimetypes 'text/css'

      identifier = /[a-zA-Z0-9_-]+/
      number = /-?(?:[0-9]+(\.[0-9]+)?|\.[0-9]+)/

      def self.attributes
        @attributes ||= Set.new %w(
          azimuth background background-attachment background-color
          background-image background-position background-repeat
          border border-bottom border-bottom-color border-bottom-style
          border-bottom-width border-collapse border-color border-left
          border-left-color border-left-style border-left-width
          border-right border-right-color border-right-style
          border-right-width border-spacing border-style border-top
          border-top-color border-top-style border-top-width
          border-width bottom caption-side clear clip color content
          counter-increment counter-reset cue cue-after cue-before cursor
          direction display elevation empty-cells float font font-family
          font-size font-size-adjust font-stretch font-style font-variant
          font-weight height left letter-spacing line-height list-style
          list-style-image list-style-position list-style-type margin
          margin-bottom margin-left margin-right margin-top marker-offset
          marks max-height max-width min-height min-width opacity orphans
          outline outline-color outline-style outline-width overflow-x
          overflow-y padding padding-bottom padding-left padding-right
          padding-top page page-break-after page-break-before
          page-break-inside pause pause-after pause-before pitch
          pitch-range play-during position quotes richness right size
          speak speak-header speak-numeral speak-punctuation speech-rate
          src stress table-layout text-align text-decoration text-indent
          text-shadow text-transform top unicode-bidi vertical-align
          visibility voice-family volume white-space widows width
          word-spacing z-index
        )
      end

      def self.builtins
        @builtins ||= Set.new %w(
          above absolute always armenian aural auto avoid left bottom
          baseline behind below bidi-override blink block bold bolder
          both bottom capitalize center center-left center-right circle
          cjk-ideographic close-quote collapse condensed continuous crop
          cross crosshair cursive dashed decimal decimal-leading-zero
          default digits disc dotted double e-resize embed expanded
          extra-condensed extra-expanded fantasy far-left far-right fast
          faster fixed georgian groove hebrew help hidden hide high higher
          hiragana hiragana-iroha icon inherit inline inline-table inset
          inside invert italic justify katakana katakana-iroha landscape
          large larger left left-side leftwards level lighter line-through
          list-item loud low lower lower-alpha lower-greek lower-roman
          lowercase ltr medium message-box middle mix monospace n-resize
          narrower ne-resize no-close-quote no-open-quote no-repeat none
          normal nowrap nw-resize oblique once open-quote outset outside
          overline pointer portrait px relative repeat repeat-x repeat-y
          rgb ridge right right-side rightwards s-resize sans-serif scroll
          se-resize semi-condensed semi-expanded separate serif show
          silent slow slower small-caps small-caption smaller soft solid
          spell-out square static status-bar super sw-resize table-caption
          table-cell table-column table-column-group table-footer-group
          table-header-group table-row table-row-group text text-bottom
          text-top thick thin top transparent ultra-condensed
          ultra-expanded underline upper-alpha upper-latin upper-roman
          uppercase url visible w-resize wait wider x-fast x-high x-large
          x-loud x-low x-small x-soft xx-large xx-small yes
        )
      end

      def self.constants
        @constants ||= Set.new %w(
          indigo gold firebrick indianred yellow darkolivegreen
          darkseagreen mediumvioletred mediumorchid chartreuse
          mediumslateblue black springgreen crimson lightsalmon brown
          turquoise olivedrab cyan silver skyblue gray darkturquoise
          goldenrod darkgreen darkviolet darkgray lightpink teal
          darkmagenta lightgoldenrodyellow lavender yellowgreen thistle
          violet navy orchid blue ghostwhite honeydew cornflowerblue
          darkblue darkkhaki mediumpurple cornsilk red bisque slategray
          darkcyan khaki wheat deepskyblue darkred steelblue aliceblue
          gainsboro mediumturquoise floralwhite coral purple lightgrey
          lightcyan darksalmon beige azure lightsteelblue oldlace
          greenyellow royalblue lightseagreen mistyrose sienna lightcoral
          orangered navajowhite lime palegreen burlywood seashell
          mediumspringgreen fuchsia papayawhip blanchedalmond peru
          aquamarine white darkslategray ivory dodgerblue lemonchiffon
          chocolate orange forestgreen slateblue olive mintcream
          antiquewhite darkorange cadetblue moccasin limegreen saddlebrown
          darkslateblue lightskyblue deeppink plum aqua darkgoldenrod
          maroon sandybrown magenta tan rosybrown pink lightblue
          palevioletred mediumseagreen dimgray powderblue seagreen snow
          mediumblue midnightblue paleturquoise palegoldenrod whitesmoke
          darkorchid salmon lightslategray lawngreen lightgreen tomato
          hotpink lightyellow lavenderblush linen mediumaquamarine green
          blueviolet peachpuff
        )
      end

      # source: http://www.w3.org/TR/CSS21/syndata.html#vendor-keyword-history
      def self.vendor_prefixes
        @vendor_prefixes ||= Set.new %w(
          -ah- -atsc- -hp- -khtml- -moz- -ms- -o- -rim- -ro- -tc- -wap-
          -webkit- -xv- mso- prince-
        )
      end

      state :root do
        mixin :basics
        rule /{/, 'Punctuation', :stanza
        rule /:#{identifier}/, 'Name.Decorator'
        rule /\.#{identifier}/, 'Name.Class'
        rule /##{identifier}/, 'Name.Function'
        rule /@#{identifier}/, 'Keyword', :at_rule
        rule identifier, 'Name.Tag'
        rule %r([~^*!%&\[\]()<>|+=@:;,./?-]), 'Operator'
      end

      state :value do
        mixin :basics
        rule /url\(.*?\)/, 'Literal.String.Other'
        rule /#[0-9a-f]{1,6}/i, 'Literal.Number' # colors
        rule /#{number}(?:em|px|%|pt|pc|in|mm|m|ex|s)?\b/, 'Literal.Number'
        rule /[\[\]():\/.]/, 'Punctuation'
        rule /"(\\\\|\\"|[^"])*"/, 'Literal.String.Single'
        rule /'(\\\\|\\'|[^'])*'/, 'Literal.String.Double'
        rule(identifier) do |m|
          if self.class.constants.include? m[0]
            token 'Name.Constant'
          elsif self.class.builtins.include? m[0]
            token 'Name.Builtin'
          else
            token 'Name'
          end
        end
      end

      state :at_rule do
        rule /{(?=\s*#{identifier}\s*:)/m, 'Punctuation', :at_stanza
        rule /{/, 'Punctuation', :at_body
        rule /;/, 'Punctuation', :pop!
        mixin :value
      end

      state :at_body do
        mixin :at_content
        mixin :root
      end

      state :at_stanza do
        mixin :at_content
        mixin :stanza
      end

      state :at_content do
        rule /}/ do
          token 'Punctuation'
          pop!; pop!
        end
      end

      state :basics do
        rule /\s+/m, 'Text'
        rule %r(/\*(?:.*?)\*/)m, 'Comment'
      end

      state :stanza do
        mixin :basics
        rule /}/, 'Punctuation', :pop!
        rule /(#{identifier})(\s*)(:)/m do |m|
          if self.class.attributes.include? m[1]
            group 'Name.Label'
          elsif self.class.vendor_prefixes.any? { |p| m[1].start_with?(p) }
            group 'Name.Label'
          else
            group 'Name.Property'
          end

          group 'Text'
          group 'Punctuation'

          push :stanza_value
        end
      end

      state :stanza_value do
        rule /;/, 'Punctuation', :pop!
        rule(/(?=})/) { pop! }
        rule /!important\b/, 'Comment.Preproc'
        rule /^@.*?$/, 'Comment.Preproc'
        mixin :value
      end
    end
  end
end
module Rouge
  module Lexers
    class Diff < RegexLexer
      desc "Lexes unified diffs or patches"

      tag 'diff'
      aliases 'patch', 'udiff'
      filenames '*.diff', '*.patch'
      mimetypes 'text/x-diff', 'text/x-patch'

      def self.analyze_text(text)
        return 1   if text.start_with?('Index: ')
        return 1   if text.start_with?('diff ')

        return 0.9 if text =~ /\A---.*?\n\+\+\+/m
      end

      state :header do
        rule /^diff .*?\n(?=---|\+\+\+)/m, 'Generic.Heading'
        rule /^--- .*?\n/, 'Generic.Deleted'
        rule /^\+\+\+ .*?\n/, 'Generic.Inserted'
      end

      state :diff do
        rule /@@ -\d+,\d+ \+\d+,\d+ @@.*?\n/, 'Generic.Heading'
        rule /^\+.*?\n/, 'Generic.Inserted'
        rule /^-.*?\n/,  'Generic.Deleted'
        rule /^ .*?\n/,  'Text'
        rule /^.*?\n/,   'Error'
      end

      state :root do
        mixin :header
        mixin :diff
      end
    end
  end
end
module Rouge
  module Lexers
    class ERB < TemplateLexer
      desc "Embedded ruby template files"

      tag 'erb'
      aliases 'eruby', 'rhtml'

      filenames '*.erb', '*.erubis', '*.rhtml', '*.eruby'

      def self.analyze_text(text)
        return 0.4 if text =~ /<%.*%>/
      end

      def initialize(opts={})
        @ruby_lexer = Ruby.new(opts)

        super(opts)
      end

      start do
        parent.reset!
        @ruby_lexer.reset!
      end

      open  = /<%%|<%=|<%#|<%-|<%/
      close = /%%>|-%>|%>/

      state :root do
        rule /<%#/, 'Comment', :comment

        rule open, 'Comment.Preproc', :ruby

        rule /.+?(?=#{open})|.+/m do
          delegate parent
        end
      end

      state :comment do
        rule close, 'Comment', :pop!
        rule /.+(?=#{close})|.+/m, 'Comment'
      end

      state :ruby do
        rule close, 'Comment.Preproc', :pop!

        rule /.+?(?=#{close})|.+/m do
          delegate @ruby_lexer
        end
      end
    end
  end
end
module Rouge
  module Lexers
    class Factor < RegexLexer
      desc "Factor, the practical stack language (factorcode.org)"
      tag 'factor'
      filenames '*.factor'
      mimetypes 'text/x-factor'

      def self.analyze_text(text)
        return 1 if text.shebang? 'factor'
      end

      def self.builtins
        @builtins ||= {}.tap do |builtins|
          builtins[:kernel] = Set.new %w(
            or 2bi 2tri while wrapper nip 4dip wrapper? bi*
            callstack>array both? hashcode die dupd callstack
            callstack? 3dup tri@ pick curry build ?execute 3bi prepose
            >boolean if clone eq? tri* ? = swapd 2over 2keep 3keep clear
            2dup when not tuple? dup 2bi* 2tri* call tri-curry object bi@
            do unless* if* loop bi-curry* drop when* assert= retainstack
            assert? -rot execute 2bi@ 2tri@ boa with either? 3drop bi
            curry?  datastack until 3dip over 3curry tri-curry* tri-curry@
            swap and 2nip throw bi-curry (clone) hashcode* compose 2dip if
            3tri unless compose? tuple keep 2curry equal? assert tri 2drop
            most <wrapper> boolean? identity-hashcode identity-tuple?
            null new dip bi-curry@ rot xor identity-tuple boolean
          )

          builtins[:assocs] = Set.new %w(
            ?at assoc? assoc-clone-like assoc= delete-at* assoc-partition
            extract-keys new-assoc value? assoc-size map>assoc push-at
            assoc-like key? assoc-intersect assoc-refine update
            assoc-union assoc-combine at* assoc-empty? at+ set-at
            assoc-all? assoc-subset?  assoc-hashcode change-at assoc-each
            assoc-diff zip values value-at rename-at inc-at enum? at cache
            assoc>map <enum> assoc assoc-map enum value-at* assoc-map-as
            >alist assoc-filter-as clear-assoc assoc-stack maybe-set-at
            substitute assoc-filter 2cache delete-at assoc-find keys
            assoc-any? unzip
          )

          builtins[:combinators] = Set.new %w(
            case execute-effect no-cond no-case? 3cleave>quot 2cleave
            cond>quot wrong-values? no-cond? cleave>quot no-case case>quot
            3cleave wrong-values to-fixed-point alist>quot case-find
            cond cleave call-effect 2cleave>quot recursive-hashcode
            linear-case-quot spread spread>quot
          )

          builtins[:math] = Set.new %w(
            number= if-zero next-power-of-2 each-integer ?1+
            fp-special? imaginary-part unless-zero float>bits number?
            fp-infinity? bignum? fp-snan? denominator fp-bitwise= *
            + power-of-2? - u>= / >= bitand log2-expects-positive <
            log2 > integer? number bits>double 2/ zero? (find-integer)
            bits>float float? shift ratio? even? ratio fp-sign bitnot
            >fixnum complex? /i /f byte-array>bignum when-zero sgn >bignum
            next-float u< u> mod recip rational find-last-integer >float
            (all-integers?) 2^ times integer fixnum? neg fixnum sq bignum
            (each-integer) bit? fp-qnan? find-integer complex <fp-nan>
            real double>bits bitor rem fp-nan-payload all-integers?
            real-part log2-expects-positive? prev-float align unordered?
            float fp-nan? abs bitxor u<= odd? <= /mod rational? >integer
            real? numerator
          )

          builtins[:sequences] = Set.new %w(
            member-eq? append assert-sequence= find-last-from
            trim-head-slice clone-like 3sequence assert-sequence? map-as
            last-index-from reversed index-from cut* pad-tail
            remove-eq! concat-as but-last snip trim-tail nths
            nth 2selector sequence slice?  <slice> partition
            remove-nth tail-slice empty? tail* if-empty
            find-from virtual-sequence? member? set-length
            drop-prefix unclip unclip-last-slice iota map-sum
            bounds-error? sequence-hashcode-step selector-for
            accumulate-as map start midpoint@ (accumulate) rest-slice
            prepend fourth sift accumulate! new-sequence follow map! like
            first4 1sequence reverse slice unless-empty padding virtual@
            repetition? set-last index 4sequence max-length set-second
            immutable-sequence first2 first3 replicate-as reduce-index
            unclip-slice supremum suffix! insert-nth trim-tail-slice
            tail 3append short count suffix concat flip filter sum
            immutable? reverse! 2sequence map-integers delete-all start*
            indices snip-slice check-slice sequence?  head map-find
            filter! append-as reduce sequence= halves collapse-slice
            interleave 2map filter-as binary-reduce slice-error? product
            bounds-check? bounds-check harvest immutable virtual-exemplar
            find produce remove pad-head last replicate set-fourth
            remove-eq shorten reversed?  map-find-last 3map-as
            2unclip-slice shorter? 3map find-last head-slice pop* 2map-as
            tail-slice* but-last-slice 2map-reduce iota? collector-for
            accumulate each selector append! new-resizable cut-slice
            each-index head-slice* 2reverse-each sequence-hashcode
            pop set-nth ?nth <flat-slice> second join when-empty
            collector immutable-sequence? <reversed> all? 3append-as
            virtual-sequence subseq? remove-nth! push-either new-like
            length last-index push-if 2all? lengthen assert-sequence
            copy map-reduce move third first 3each tail? set-first prefix
            bounds-error any? <repetition> trim-slice exchange surround
            2reduce cut change-nth min-length set-third produce-as
            push-all head? delete-slice rest sum-lengths 2each head*
            infimum remove! glue slice-error subseq trim replace-slice
            push repetition map-index trim-head unclip-last mismatch
          )

          builtins[:namespaces] = Set.new %w(
            global +@ change set-namestack change-global init-namespaces
            on off set-global namespace set with-scope bind with-variable
            inc dec counter initialize namestack get get-global make-assoc
          )

          builtins[:arrays] = Set.new %w(
            <array> 2array 3array pair >array 1array 4array pair?
            array resize-array array?
          )

          builtins[:io] = Set.new %w(
            +character+ bad-seek-type? readln each-morsel
            stream-seek read print with-output-stream contents
            write1 stream-write1 stream-copy stream-element-type
            with-input-stream stream-print stream-read stream-contents
            stream-tell tell-output bl seek-output bad-seek-type nl
            stream-nl write flush stream-lines +byte+ stream-flush
            read1 seek-absolute? stream-read1 lines stream-readln
            stream-read-until each-line seek-end with-output-stream*
            seek-absolute with-streams seek-input seek-relative?
            input-stream stream-write read-partial seek-end?
            seek-relative error-stream read-until with-input-stream*
            with-streams* tell-input each-block output-stream
            stream-read-partial each-stream-block each-stream-line
          )

          builtins[:strings] = Set.new %w(
            resize-string >string <string> 1string string string?
          )

          builtins[:vectors] = Set.new %w(
            with-return restarts return-continuation with-datastack
            recover rethrow-restarts <restart> ifcc set-catchstack
            >continuation< cleanup ignore-errors restart?
            compute-restarts attempt-all-error error-thread
            continue <continuation> attempt-all-error? condition?
            <condition> throw-restarts error catchstack continue-with
            thread-error-hook continuation rethrow callcc1
            error-continuation callcc0 attempt-all condition
            continuation? restart return
          )

          builtins[:continuations] = Set.new %w(
            with-return restarts return-continuation with-datastack
            recover rethrow-restarts <restart> ifcc set-catchstack
            >continuation< cleanup ignore-errors restart?
            compute-restarts attempt-all-error error-thread
            continue <continuation> attempt-all-error? condition?
            <condition> throw-restarts error catchstack continue-with
            thread-error-hook continuation rethrow callcc1
            error-continuation callcc0 attempt-all condition
            continuation? restart return
          )
        end
      end

      state :root do
        rule /\s+/m, 'Text'

        rule /(:|::|MACRO:|MEMO:|GENERIC:|HELP:)(\s+)(\S+)/m do
          group 'Keyword'; group 'Text'
          group 'Name.Function'
        end

        rule /(M:|HOOK:|GENERIC#)(\s+)(\S+)(\s+)(\S+)/m do
          group 'Keyword'; group 'Text'
          group 'Name.Class'; group 'Text'
          group 'Name.Function'
        end

        rule /\((?=\s)/, 'Name.Function', :stack_effect
        rule /;(?=\s)/, 'Keyword'

        rule /(USING:)((?:\s|\\\s)+)/m do
          group 'Keyword.Namespace'; group 'Text'
          push :import
        end

        rule /(IN:|USE:|UNUSE:|QUALIFIED:|QUALIFIED-WITH:)(\s+)(\S+)/m do
          group 'Keyword.Namespace'; group 'Text'; group 'Name.Namespace'
        end

        rule /(FROM:|EXCLUDE:)(\s+)(\S+)(\s+)(=>)/m do
          group 'Keyword.Namespace'; group 'Text'
          group 'Name.Namespace'; group 'Text'
          group 'Punctuation'
        end

        rule /(?:ALIAS|DEFER|FORGET|POSTPONE):/, 'Keyword.Namespace'

        rule /(TUPLE:)(\s+)(\S+)(\s+)(<)(\s+)(\S+)/m do
          group 'Keyword'; group 'Text'
          group 'Name.Class'; group 'Text'
          group 'Punctuation'; group 'Text'
          group 'Name.Class'
          push :slots
        end

        rule /(TUPLE:)(\s+)(\S+)/m do
          group 'Keyword'; group 'Text'; group 'Name.Class'
          push :slots
        end

        rule /(UNION:|INTERSECTION:)(\s+)(\S+)/m do
          group 'Keyword'; group 'Text'; group 'Name.Class'
        end

        rule /(PREDICATE:)(\s+)(\S+)(\s+)(<)(\s+)(\S+)/m do
          group 'Keyword'; group 'Text'
          group 'Name.Class'; group 'Text'
          group 'Punctuation'; group 'Text'
          group 'Name.Class'
        end

        rule /(C:)(\s+)(\S+)(\s+)(\S+)/m do
          group 'Keyword'; group 'Text'
          group 'Name.Function'; group 'Text'
          group 'Name.Class'
        end

        rule %r(
          (INSTANCE|SLOT|MIXIN|SINGLETONS?|CONSTANT|SYMBOLS?|ERROR|SYNTAX
           |ALIEN|TYPEDEF|FUNCTION|STRUCT):
        )x, 'Keyword'

        rule /(?:<PRIVATE|PRIVATE>)/, 'Keyword.Namespace'

        rule /(MAIN:)(\s+)(\S+)/ do
          group 'Keyword.Namespace'; group 'Text'; group 'Name.Function'
        end

        # strings
        rule /"""\s+.*?\s+"""/, 'Literal.String'
        rule /"(\\.|[^\\])*?"/, 'Literal.String'
        rule /(CHAR:)(\s+)(\\[\\abfnrstv]*|\S)(?=\s)/, 'Literal.String.Char'

        # comments
        rule /!\s+.*$/, 'Comment'
        rule /#!\s+.*$/, 'Comment'

        # booleans
        rule /[tf](?=\s)/, 'Name.Constant'

        # numbers
        rule /-?\d+\.\d+(?=\s)/, 'Literal.Number.Float'
        rule /-?\d+(?=\s)/, 'Literal.Number.Integer'

        rule /HEX:\s+[a-fA-F\d]+(?=\s)/m, 'Literal.Number.Hex'
        rule /BIN:\s+[01]+(?=\s)/, 'Literal.Number.Bin'
        rule /OCT:\s+[0-7]+(?=\s)/, 'Literal.Number.Oct'

        rule %r([-+/*=<>^](?=\s)), 'Operator'

        rule /(?:deprecated|final|foldable|flushable|inline|recursive)(?=\s)/,
          'Keyword'

        # words, to be postprocessed for builtins and things
        rule /\S+/, 'Postprocess.Word'
      end

      state :stack_effect do
        rule /\s+/, 'Text'
        rule /\(/, 'Name.Function', :stack_effect
        rule /\)/, 'Name.Function', :pop!

        rule /--/, 'Name.Function'
        rule /\S+/, 'Name.Variable'
      end

      state :slots do
        rule /\s+/, 'Text'
        rule /;(?=\s)/, 'Keyword', :pop!
        rule /\S+/, 'Name.Variable'
      end

      state :import do
        rule /;(?=\s)/, 'Keyword', :pop!
        rule /\s+/, 'Text'
        rule /\S+/, 'Name.Namespace'
      end

      postprocess 'Postprocess.Word' do |tok, val|
        tok = if self.class.builtins.values.any? { |b| b.include? val }
          'Name.Builtin'
        else
          'Name'
        end

        token tok, val
      end
    end
  end
end
module Rouge
  module Lexers
    class Groovy < RegexLexer
      desc 'The Groovy programming language (groovy.codehaus.org)'
      tag 'groovy'
      filenames '*.groovy'
      mimetypes 'text/x-groovy'

      ws = %r((?:\s|//.*?\n|/[*].*?[*]/)+)

      def self.keywords
        @keywords ||= Set.new %w(
          assert break case catch continue default do else finally for
          if goto instanceof new return switch this throw try while in as
        )
      end

      def self.declarations
        @declarations ||= Set.new %w(
          abstract const enum extends final implements native private
          protected public static strictfp super synchronized throws
          transient volatile
        )
      end

      def self.types
        @types ||= Set.new %w(
          def boolean byte char double float int long short void
        )
      end

      def self.constants
        @constants ||= Set.new %w(true false null)
      end

      state :root do
        rule %r(^
          (\s*(?:\w[\w\d.\[\]]*\s+)+?) # return arguments
          (\w[\w\d]*) # method name
          (\s*) (\() # signature start
        )x do |m|
          delegate self.clone, m[1]
          token 'Name.Function', m[2]
          token 'Text', m[3]
          token 'Operator', m[4]
        end

        # whitespace
        rule /[^\S\n]+/, 'Text'
        rule %r(//.*?\n), 'Comment.Single'
        rule %r(/[*].*?[*]/), 'Comment.Multiline'
        rule /@\w[\w\d.]*/, 'Name.Decorator'
        rule /(class|interface)\b/,  'Keyword.Declaration', :class
        rule /package\b/, 'Keyword.Namespace', :import
        rule /import\b/, 'Keyword.Namespace', :import

        rule /"(\\\\|\\"|[^"])*"/, 'Literal.String.Double'
        rule /'(\\\\|\\'|[^'])*'/, 'Literal.String.Single'
        rule %r(\$/((?!/\$).)*/\$), 'Literal.String'
        rule %r(/(\\\\|\\"|[^/])*/), 'Literal.String'
        rule /'\\.'|'[^\\]'|'\\u[0-9a-f]{4}'/, 'Literal.String.Char'
        rule /(\.)([a-zA-Z_][a-zA-Z0-9_]*)/ do
          group 'Operator'
          group 'Name.Attribute'
        end

        rule /[a-zA-Z_][a-zA-Z0-9_]*:/, 'Name.Label'
        rule /[a-zA-Z_\$][a-zA-Z0-9_]*/ do |m|
          if self.class.keywords.include? m[0]
            token 'Keyword'
          elsif self.class.declarations.include? m[0]
            token 'Keyword.Declaration'
          elsif self.class.types.include? m[0]
            token 'Keyword.Type'
          elsif self.class.constants.include? m[0]
            token 'Keyword.Constant'
          else
            token 'Name'
          end
        end

        rule %r([~^*!%&\[\](){}<>\|+=:;,./?-]), 'Operator'

        # numbers
        rule /\d+\.\d+([eE]\d+)?[fd]?/, 'Literal.Number.Float'
        rule /0x[0-9a-f]+/, 'Literal.Number.Hex'
        rule /[0-9]+L?/, 'Literal.Number.Integer'
        rule /\n/, 'Text'
      end

      state :class do
        rule /\s+/, 'Text'
        rule /\w[\w\d]*/, 'Name.Class', :pop!
      end

      state :import do
        rule /\s+/, 'Text'
        rule /[\w\d.]+[*]?/, 'Name.Namespace', :pop!
      end
    end
  end
end
module Rouge
  module Lexers
    # A lexer for the Haml templating system for Ruby.
    # @see http://haml.info
    class Haml < RegexLexer
      include Indentation

      desc "The Haml templating system for Ruby (haml.info)"

      tag 'haml'
      aliases 'HAML'

      filenames '*.haml'
      mimetypes 'text/x-haml'

      def self.analyze_text(text)
        return 0.1 if text.start_with? '!!!'
      end

      # @option opts :filters
      #   A hash of filter name to lexer of how various filters should be
      #   highlighted.  By default, :javascript, :css, :ruby, and :erb
      #   are supported.
      def initialize(opts={})
        (opts.delete(:filters) || {}).each do |name, lexer|
          unless lexer.respond_to? :lex
            lexer = Lexer.find(lexer) or raise "unknown lexer: #{lexer}"
            lexer = lexer.new(options)
          end

          self.filters[name.to_s] = lexer
        end

        super(opts)
      end

      def ruby
        @ruby ||= Ruby.new(options)
      end

      def html
        @html ||= HTML.new(options)
      end

      def filters
        @filters ||= {
          'javascript' => Javascript.new(options),
          'css' => CSS.new(options),
          'ruby' => ruby,
          'erb' => ERB.new(options),
          'markdown' => Markdown.new(options),
          # TODO
          # 'sass' => Sass.new(options),
          # 'textile' => Textile.new(options),
          # 'maruku' => Maruku.new(options),
        }
      end

      start { ruby.reset!; html.reset! }

      identifier = /[\w:-]+/
      ruby_var = /[a-z]\w*/

      # Haml can include " |\n" anywhere,
      # which is ignored and used to wrap long lines.
      # To accomodate this, use this custom faux dot instead.
      dot = /[ ]\|\n(?=.*[ ]\|)|./

      # In certain places, a comma at the end of the line
      # allows line wrapping as well.
      comma_dot = /,\s*\n|#{dot}/

      state :root do
        rule /\s*\n/, 'Text'
        rule(/\s*/) { |m| token 'Text'; indentation(m[0]) }
      end

      state :content do
        mixin :css
        rule(/%#{identifier}/) { token 'Name.Tag'; pop!; push :tag }
        rule /!!!#{dot}*\n/, 'Name.Namespace', :pop!
        rule %r(
          (/) (\[#{dot}*?\]) (#{dot}*\n)
        )x do
          group 'Comment'; group 'Comment.Special'; group 'Comment'
          pop!
        end

        rule %r(/#{dot}*\n) do
          token 'Comment'
          pop!
          starts_block :html_comment_block
        end

        rule /-##{dot}*\n/ do
          token 'Comment'
          pop!
          starts_block :haml_comment_block
        end

        rule /-/ do
          token 'Punctuation'
          reset_stack
          push :ruby_line
        end

        # filters
        rule /:(#{dot}*)\n/ do |m|
          token 'Name.Decorator'
          pop!
          starts_block :filter_block

          filter_name = m[1].strip

          @filter_lexer = self.filters[filter_name]
          @filter_lexer.reset! unless @filter_lexer.nil?

          debug { "    haml: filter #{filter_name.inspect} #{@filter_lexer.inspect}" }
        end

        mixin :eval_or_plain
      end

      state :css do
        rule(/\.#{identifier}/) { token 'Name.Class'; pop!; push :tag }
        rule(/##{identifier}/) { token 'Name.Function'; pop!; push :tag }
      end

      state :tag do
        mixin :css
        rule(/\{#{comma_dot}*?\}/) { delegate ruby }
        rule(/\[#{dot}*?\]/) { delegate ruby }
        rule /\(/, 'Punctuation', :html_attributes
        rule /\s*\n/, 'Text', :pop!

        # whitespace chompers
        rule /[<>]{1,2}(?=[ \t=])/, 'Punctuation'

        mixin :eval_or_plain
      end

      state :plain do
        rule(/([^#\n]|#[^{\n]|(\\\\)*\\#\{)+/) { delegate html }
        mixin :interpolation
        rule(/\n/) { token 'Text'; reset_stack }
      end

      state :eval_or_plain do
        rule /[&!]?==/, 'Punctuation', :plain
        rule /[&!]?[=!]/ do
          token 'Punctuation'
          reset_stack
          push :ruby_line
        end

        rule(//) { push :plain }
      end

      state :ruby_line do
        rule /\n/, 'Text', :pop!
        rule(/,[ \t]*\n/) { delegate ruby }
        rule /[ ]\|[ \t]*\n/, 'Literal.String.Escape'
        rule(/.*?(?=(,$| \|)?[ \t]*$)/) { delegate ruby }
      end

      state :html_attributes do
        rule /\s+/, 'Text'
        rule /#{identifier}\s*=/, 'Name.Attribute', :html_attribute_value
        rule identifier, 'Name.Attribute'
        rule /\)/, 'Text', :pop!
      end

      state :html_attribute_value do
        rule /\s+/, 'Text'
        rule ruby_var, 'Name.Variable', :pop!
        rule /@#{ruby_var}/, 'Name.Variable.Instance', :pop!
        rule /\$#{ruby_var}/, 'Name.Variable.Global', :pop!
        rule /'(\\\\|\\'|[^'\n])*'/, 'Literal.String', :pop!
        rule /"(\\\\|\\"|[^"\n])*"/, 'Literal.String', :pop!
      end

      state :html_comment_block do
        rule /#{dot}+/, 'Comment'
        mixin :indented_block
      end

      state :haml_comment_block do
        rule /#{dot}+/, 'Comment.Preproc'
        mixin :indented_block
      end

      state :filter_block do
        rule /([^#\n]|#[^{\n]|(\\\\)*\\#\{)+/ do
          if @filter_lexer
            delegate @filter_lexer
          else
            token 'Name.Decorator'
          end
        end

        mixin :interpolation
        mixin :indented_block
      end

      state :interpolation do
        rule /(#\{)(#{dot}*?)(\})/ do |m|
          token 'Literal.String.Interpol', m[1]
          delegate ruby, m[2]
          token 'Literal.String.Interpol', m[3]
        end
      end

      state :indented_block do
        rule(/\n/) { token 'Text'; reset_stack }
      end
    end
  end
end
module Rouge
  module Lexers
    class Handlebars < TemplateLexer
      desc 'the Handlebars and Mustache templating languages'
      tag 'handlebars'
      aliases 'hbs', 'mustache'
      filenames '*.handlebars', '*.hbs', '*.mustache'
      mimetypes 'text/x-handlebars', 'text/x-mustache'

      id = %r([\w$-]+)

      state :root do
        # escaped slashes
        rule(/\\{+/) { delegate parent }

        # block comments
        rule /{{!--/, 'Comment', :comment
        rule /{{!.*?}}/, 'Comment'

        rule /{{{?/ do
          token 'Keyword'
          push :stache
          push :open_sym
        end

        rule(/(.+?)(?=\\|{{)/m) { delegate parent }

        # if we get here, there's no more mustache tags, so we eat
        # the rest of the doc
        rule(/.+/m) { delegate parent }
      end

      state :comment do
        rule(/{{/) { token 'Comment'; push }
        rule(/}}/) { token 'Comment'; pop! }
        rule(/[^{}]+/m) { token 'Comment' }
        rule(/[{}]/) { token 'Comment' }
      end

      state :stache do
        rule /}}}?/, 'Keyword', :pop!
        rule /\s+/m, 'Text'
        rule /[=]/, 'Operator'
        rule /[\[\]]/, 'Punctuation'
        rule /[.](?=[}\s])/, 'Name.Variable'
        rule /[.][.]/, 'Name.Variable'
        rule %r([/.]), 'Punctuation'
        rule /"(\\.|.)*?"/, 'Literal.String.Double'
        rule /'(\\.|.)*?'/, 'Literal.String.Single'
        rule /\d+(?=}\s)/, 'Literal.Number'
        rule /(true|false)(?=[}\s])/, 'Keyword.Constant'
        rule /else(?=[}\s])/, 'Keyword'
        rule /this(?=[}\s])/, 'Name.Builtin.Pseudo'
        rule /@#{id}/, 'Name.Attribute'
        rule id, 'Name.Variable'
      end

      state :open_sym do
        rule %r([#/]) do
          token 'Keyword'
          pop!; push :block_name
        end

        rule /[>^&]/, 'Keyword'

        rule(//) { pop! }
      end

      state :block_name do
        rule /if(?=[}\s])/, 'Keyword'
        rule id, 'Name.Namespace', :pop!
        rule(//) { pop! }
      end
    end
  end
end
module Rouge
  module Lexers
    class Haskell < RegexLexer
      desc "The Haskell programming language (haskell.org)"

      tag 'haskell'
      aliases 'hs'
      filenames '*.hs'
      mimetypes 'text/x-haskell'

      def self.analyze_text(text)
        return 1 if text.shebang?('runhaskell')
      end

      reserved = %w(
        _ case class data default deriving do else if in
        infix[lr]? instance let newtype of then type where
      )

      ascii = %w(
        NUL SOH [SE]TX EOT ENQ ACK BEL BS HT LF VT FF CR S[OI] DLE
        DC[1-4] NAK SYN ETB CAN EM SUB ESC [FGRU]S SP DEL
      )

      state :basic do
        rule /\s+/m, 'Text'
        rule /{-#/, 'Comment.Preproc', :comment_preproc
        rule /{-/, 'Comment.Multiline', :comment
        rule /^--\s+\|.*?$/, 'Comment.Doc'
        # this is complicated in order to support custom symbols
        # like -->
        rule /--(?![!#\$\%&*+.\/<=>?@\^\|_~]).*?$/, 'Comment.Single'
      end

      # nested commenting
      state :comment do
        rule /-}/, 'Comment.Multiline', :pop!
        rule /{-/, 'Comment.Multiline', :comment
        rule /[^-{}]+/, 'Comment.Multiline'
        rule /[-{}]/, 'Comment.Multiline'
      end

      state :comment_preproc do
        rule /-}/, 'Comment.Preproc', :pop!
        rule /{-/, 'Comment.Preproc', :comment
        rule /[^-{}]+/, 'Comment.Preproc'
        rule /[-{}]/, 'Comment.Preproc'
      end

      state :root do
        mixin :basic

        rule /\bimport\b/, 'Keyword.Reserved', :import
        rule /\bmodule\b/, 'Keyword.Reserved', :module
        rule /\berror\b/, 'Name.Exception'
        rule /\b(?:#{reserved.join('|')})\b/, 'Keyword.Reserved'
        # not sure why, but ^ doesn't work here
        # rule /^[_a-z][\w']*/, 'Name.Function'
        rule /[_a-z][\w']*/, 'Name'
        rule /[A-Z][\w']*/, 'Keyword.Type'

        # lambda operator
        rule %r(\\(?![:!#\$\%&*+.\\/<=>?@^\|~-]+)), 'Name.Function'
        # special operators
        rule %r((<-|::|->|=>|=)(?![:!#\$\%&*+.\\/<=>?@^\|~-]+)), 'Operator'
        # constructor/type operators
        rule %r(:[:!#\$\%&*+.\\/<=>?@^\|~-]*), 'Operator'
        # other operators
        rule %r([:!#\$\%&*+.\\/<=>?@^\|~-]+), 'Operator'

        rule /\d+e[+-]?\d+/i, 'Literal.Number.Float'
        rule /\d+\.\d+(e[+-]?\d+)?/i, 'Literal.Number.Float'
        rule /0o[0-7]+/i, 'Literal.Number.Oct'
        rule /0x[\da-f]+/i, 'Literal.Number.Hex'
        rule /\d+/, 'Literal.Number.Integer'

        rule /'/, 'Literal.String.Char', :character
        rule /"/, 'Literal.String', :string

        rule /\[\s*\]/, 'Keyword.Type'
        rule /\(\s*\)/, 'Name.Builtin'
        rule /[\[\](),;`{}]/, 'Punctuation'
      end

      state :import do
        rule /\s+/, 'Text'
        rule /"/, 'Literal.String', :string
        rule /\bqualified\b/, 'Keyword'
        # import X as Y
        rule /([A-Z][\w.]*)(\s+)(as)(\s+)([A-Z][a-zA-Z0-9_.]*)/ do
          group 'Name.Namespace' # X
          group 'Text'
          group 'Keyword' # as
          group 'Text'
          group 'Name' # Y
          pop!
        end

        # import X hiding (functions)
        rule /([A-Z][\w.]*)(\s+)(hiding)(\s+)(\()/ do
          group 'Name.Namespace' # X
          group 'Text'
          group 'Keyword' # hiding
          group 'Text'
          group 'Punctuation' # (
          pop!
          push :funclist
        end

        # import X (functions)
        rule /([A-Z][\w.]*)(\s+)(\()/ do
          group 'Name.Namespace' # X
          group 'Text'
          group 'Punctuation' # (
          pop!
          push :funclist
        end

        rule /[\w.]+/, 'Name.Namespace', :pop!
      end

      state :module do
        rule /\s+/, 'Text'
        # module Foo (functions)
        rule /([A-Z][\w.]*)(\s+)(\()/ do
          group 'Name.Namespace'
          group 'Text'
          group 'Punctuation'
          push :funclist
        end

        rule /\bwhere\b/, 'Keyword.Reserved', :pop!

        rule /[A-Z][a-zA-Z0-9_.]*/, 'Name.Namespace', :pop!
      end

      state :funclist do
        mixin :basic
        rule /[A-Z]\w*/, 'Keyword.Type'
        rule /(_[\w\']+|[a-z][\w\']*)/, 'Name.Function'
        rule /,/, 'Punctuation'
        rule /[:!#\$\%&*+.\\\/<=>?@^\|~-]+/, 'Operator'
        rule /\(/, 'Punctuation', :funclist
        rule /\)/, 'Punctuation', :pop!
      end

      state :character do
        rule /\\/ do
          token 'Literal.String.Escape'
          push :character_end
          push :escape
        end

        rule /./ do
          token 'Literal.String.Char'
          pop!
          push :character_end
        end
      end

      state :character_end do
        rule /'/, 'Literal.String.Char', :pop!
        rule /./, 'Error', :pop!
      end

      state :string do
        rule /"/, 'Literal.String', :pop!
        rule /\\/, 'Literal.String.Escape', :escape
        rule /[^\\"]+/, 'Literal.String'
      end

      state :escape do
        rule /[abfnrtv"'&\\]/, 'Literal.String.Escape', :pop!
        rule /\^[\]\[A-Z@\^_]/, 'Literal.String.Escape', :pop!
        rule /#{ascii.join('|')}/, 'Literal.String.Escape', :pop!
        rule /o[0-7]+/i, 'Literal.String.Escape', :pop!
        rule /x[\da-f]/i, 'Literal.String.Escape', :pop!
        rule /\d+/, 'Literal.String.Escape', :pop!
        rule /\s+\\/, 'Literal.String.Escape', :pop!
      end
    end
  end
end
module Rouge
  module Lexers
    class HTML < RegexLexer
      desc "HTML, the markup language of the web"
      tag 'html'
      filenames '*.htm', '*.html', '*.xhtml', '*.xslt'
      mimetypes 'text/html', 'application/xhtml+xml'

      def self.analyze_text(text)
        return 1 if text.doctype?(/\bhtml\b/i)
        return 1 if text =~ /<\s*html\b/
      end

      state :root do
        rule /[^<&]+/m, 'Text'
        rule /&\S*?;/, 'Name.Entity'
        rule /<!DOCTYPE .*?>/i, 'Comment.Preproc'
        rule /<!\[CDATA\[.*?\]\]>/m, 'Comment.Preproc'
        rule /<!--/, 'Comment', :comment
        rule /<\?.*?\?>/m, 'Comment.Preproc' # php? really?

        rule /<\s*script\s*/m do
          token 'Name.Tag'
          push :script_content
          push :tag
        end

        rule /<\s*style\s*/m do
          token 'Name.Tag'
          push :style_content
          push :tag
        end

        rule %r(<\s*[a-zA-Z0-9:]+), 'Name.Tag', :tag # opening tags
        rule %r(<\s*/\s*[a-zA-Z0-9:]+\s*>), 'Name.Tag' # closing tags
      end

      state :comment do
        rule /[^-]+/, 'Comment'
        rule /-->/, 'Comment', :pop!
        rule /-/, 'Comment'
      end

      state :tag do
        rule /\s+/m, 'Text'
        rule /[a-zA-Z0-9_:-]+\s*=/m, 'Name.Attribute', :attr
        rule /[a-zA-Z0-9_:-]+/, 'Name.Attribute'
        rule %r(/?\s*>)m, 'Name.Tag', :pop!
      end

      state :attr do
        # TODO: are backslash escapes valid here?
        rule /"/ do
          token 'Literal.String'
          pop!; push :dq
        end

        rule /'/ do
          token 'Literal.String'
          pop!; push :sq
        end

        rule /[^\s>]+/, 'Literal.String', :pop!
      end

      state :dq do
        rule /"/, 'Literal.String', :pop!
        rule /[^"]+/, 'Literal.String'
      end

      state :sq do
        rule /'/, 'Literal.String', :pop!
        rule /[^']+/, 'Literal.String'
      end

      state :script_content do
        rule %r(<\s*/\s*script\s*>)m, 'Name.Tag', :pop!
        rule %r(.*?(?=<\s*/\s*script\s*>))m do
          delegate Javascript
        end
      end

      state :style_content do
        rule %r(<\s*/\s*style\s*>)m, 'Name.Tag', :pop!
        rule %r(.*(?=<\s*/\s*style\s*>))m do
          delegate CSS
        end
      end
    end
  end
end
module Rouge
  module Lexers
    class Java < RegexLexer
      desc "The Java programming language (java.com)"

      tag 'java'
      filenames '*.java'
      mimetypes 'text/x-java'

      keywords = %w(
        assert break case catch continue default do else finally for
        if goto instanceof new return switch this throw try while
      )

      declarations = %w(
        abstract const enum extends final implements native private protected
        public static strictfp super synchronized throws transient volatile
      )

      types = %w(boolean byte char double float int long short void)

      id = /[a-zA-Z_][a-zA-Z0-9_]*/

      state :root do
        rule %r(^
          (\s*(?:[a-zA-Z_][a-zA-Z0-9_.\[\]]*\s+)+?) # return arguments
          ([a-zA-Z_][a-zA-Z0-9_]*)                  # method name
          (\s*)(\()                                 # signature start
        )mx do |m|
          # TODO: do this better, this shouldn't need a delegation
          delegate Java, m[1]
          token 'Name.Function', m[2]
          token 'Text', m[3]
          token 'Punctuation', m[4]
        end

        rule /\s+/, 'Text'
        rule %r(//.*?$), 'Comment.Single'
        rule %r(/\*.*?\*/)m, 'Comment.Multiline'
        rule /@#{id}/, 'Name.Decorator'
        rule /(?:#{keywords.join('|')})\b/, 'Keyword'
        rule /(?:#{declarations.join('|')})\b/, 'Keyword.Declaration'
        rule /(?:#{types.join('|')})/, 'Keyword.Type'
        rule /package\b/, 'Keyword.Namespace'
        rule /(?:true|false|null)\b/, 'Keyword.Constant'
        rule /(?:class|interface)\b/, 'Keyword.Declaration', :class
        rule /import\b/, 'Keyword.Namespace', :import
        rule /"(\\\\|\\"|[^"])*"/, 'Literal.String'
        rule /'(?:\\.|[^\\]|\\u[0-9a-f]{4})'/, 'Literal.String.Char'
        rule /(\.)(#{id})/ do
          group 'Operator'
          group 'Name.Attribute'
        end
        rule /#{id}:/, 'Name.Label'
        rule /\$?#{id}/, 'Name'
        rule /[~^*!%&\[\](){}<>\|+=:;,.\/?-]/, 'Operator'
        rule /[0-9][0-9]*\.[0-9]+([eE][0-9]+)?[fd]?/, 'Literal.Number.Float'
        rule /0x[0-9a-f]+/, 'Literal.Number.Hex'
        rule /[0-9]+L?/, 'Literal.Number.Integer'
        # rule /\n/, 'Text'
      end

      state :class do
        rule /\s+/m, 'Text'
        rule id, 'Name.Class', :pop!
      end

      state :import do
        rule /\s+/m, 'Text'
        rule /[a-z0-9_.]+\*?/i, 'Name.Namespace', :pop!
      end
    end
  end
end
module Rouge
  module Lexers
    class Javascript < RegexLexer
      desc "JavaScript, the browser scripting language"

      tag 'javascript'
      aliases 'js'
      filenames '*.js'
      mimetypes 'application/javascript', 'application/x-javascript',
                'text/javascript', 'text/x-javascript'

      def self.analyze_text(text)
        return 1 if text.shebang?('node')
        return 1 if text.shebang?('jsc')
        # TODO: rhino, spidermonkey, etc
      end

      state :comments_and_whitespace do
        rule /\s+/, 'Text'
        rule /<!--/, 'Comment' # really...?
        rule %r(//.*?\n), 'Comment.Single'
        rule %r(/\*.*?\*/), 'Comment.Multiline'
      end

      state :slash_starts_regex do
        mixin :comments_and_whitespace

        rule %r(
          / # opening slash
          ( \\. # escape sequences
          | [^/\\\n] # regular characters
          | \[ (\\. | [^\]\\\n])* \] # character classes
          )+
          / # closing slash
          (?:[gim]+\b|\B) # flags
        )x, 'Literal.String.Regex', :pop!

        # if it's not matched by the above r.e., it's not
        # a valid expression, so we use :bad_regex to eat until the
        # end of the line.
        rule %r(/), 'Literal.String.Regex', :bad_regex
        rule //, 'Text', :pop!
      end

      state :bad_regex do
        rule /[^\n]+/, 'Error', :pop!
      end

      def self.keywords
        @keywords ||= Set.new %w(
          for in while do break return continue switch case default
          if else throw try catch finally new delete typeof instanceof
          void this
        )
      end

      def self.declarations
        @declarations ||= Set.new %w(var let with function)
      end

      def self.reserved
        @reserved ||= Set.new %w(
          abstract boolean byte char class const debugger double enum
          export extends final float goto implements import int interface
          long native package private protected public short static
          super synchronized throws transient volatile
        )
      end

      def self.constants
        @constants ||= Set.new %w(true false null NaN Infinity undefined)
      end

      def self.builtins
        @builtins ||= %w(
          Array Boolean Date Error Function Math netscape
          Number Object Packages RegExp String sun decodeURI
          decodeURIComponent encodeURI encodeURIComponent
          Error eval isFinite isNaN parseFloat parseInt document this
          window
        )
      end

      id = /[$a-zA-Z_][a-zA-Z0-9_]*/

      state :root do
        rule /\A\s*#!.*?\n/m, 'Comment.Preproc'
        rule %r((?<=\n)(?=\s|/|<!--)), 'Text', :slash_starts_regex
        mixin :comments_and_whitespace
        rule %r(\+\+ | -- | ~ | && | \|\| | \\(?=\n) | << | >>>? | ===
               | !== )x,
          'Operator', :slash_starts_regex
        rule %r([-<>+*%&|\^/!=]=?), 'Operator', :slash_starts_regex
        rule /[(\[;,]/, 'Punctuation', :slash_starts_regex
        rule /[)\].]/, 'Punctuation'

        rule /[?]/ do
          token 'Punctuation'
          push :ternary
          push :slash_starts_regex
        end

        rule /[{](?=\s*(#{id}|"[^\n]*?")\s*:)/, 'Punctuation', :object

        rule /[{]/ do
          token 'Punctuation'
          push :block
          push :slash_starts_regex
        end

        rule id do |m|
          if self.class.keywords.include? m[0]
            token 'Keyword'
            push :slash_starts_regex
          elsif self.class.declarations.include? m[0]
            token 'Keyword.Declaration'
            push :slash_starts_regex
          elsif self.class.reserved.include? m[0]
            token 'Keyword.Reserved'
          elsif self.class.constants.include? m[0]
            token 'Keyword.Constant'
          elsif self.class.builtins.include? m[0]
            token 'Name.Builtin'
          else
            token 'Name.Other'
          end
        end

        rule /[0-9][0-9]*\.[0-9]+([eE][0-9]+)?[fd]?/, 'Literal.Number.Float'
        rule /0x[0-9a-fA-F]+/, 'Literal.Number.Hex'
        rule /[0-9]+/, 'Literal.Number.Integer'
        rule /"(\\\\|\\"|[^"])*"/, 'Literal.String.Double'
        rule /'(\\\\|\\'|[^'])*'/, 'Literal.String.Single'
      end

      # braced parts that aren't object literals
      state :block do
        rule /(#{id})(\s*)(:)/ do
          group 'Name.Label'; group 'Text'
          group 'Punctuation'
        end

        rule /[}]/, 'Punctuation', :pop!
        mixin :root
      end

      # object literals
      state :object do
        rule /[}]/, 'Punctuation', :pop!
        rule /(#{id})(\s*)(:)/ do
          group 'Name.Attribute'; group 'Text'
          group 'Punctuation'
        end
        mixin :root
      end

      # ternary expressions, where <id>: is not a label!
      state :ternary do
        rule /:/, 'Punctuation', :pop!
        mixin :root
      end
    end

    class JSON < RegexLexer
      desc "JavaScript Object Notation (json.org)"
      tag 'json'
      filenames '*.json'
      mimetypes 'application/json'

      # TODO: is this too much of a performance hit?  JSON is quite simple,
      # so I'd think this wouldn't be too bad, but for large documents this
      # could mean doing two full lexes.
      def self.analyze_text(text)
        return 0.8 if text =~ /\A\s*{/m && text.lexes_cleanly?(self)
      end

      state :root do
        mixin :whitespace
        # special case for empty objects
        rule /(\{)(\s*)(\})/ do
          group 'Punctuation'
          group 'Text.Whitespace'
          group 'Punctuation'
        end
        rule /{/,  'Punctuation', :object_key
        rule /\[/, 'Punctuation', :array
        rule /-?(?:0|[1-9]\d*)\.\d+(?:e[+-]\d+)?/i, 'Literal.Number.Float'
        rule /-?(?:0|[1-9]\d*)(?:e[+-]\d+)?/i, 'Literal.Number.Integer'
        mixin :has_string
      end

      state :whitespace do
        rule /\s+/m, 'Text.Whitespace'
      end

      state :has_string do
        rule /"(\\.|[^"])*"/, 'Literal.String.Double'
      end

      state :object_key do
        mixin :whitespace
        rule /:/, 'Punctuation', :object_val
        rule /}/, 'Error', :pop!
        mixin :has_string
      end

      state :object_val do
        rule /,/, 'Punctuation', :pop!
        rule(/}/) { token 'Punctuation'; pop!; pop! }
        mixin :root
      end

      state :array do
        rule /\]/, 'Punctuation', :pop!
        rule /,/, 'Punctuation'
        mixin :root
      end
    end
  end
end
module Rouge
  module Lexers
    class Make < RegexLexer
      desc "Makefile syntax"
      tag 'make'
      aliases 'makefile', 'mf', 'gnumake', 'bsdmake'
      filenames '*.make', 'Makefile', 'makefile', 'Makefile.*', 'GNUmakefile'
      mimetypes 'text/x-makefile'

      def self.analyze_text(text)
        return 0.2 if text =~ /^\.PHONY:/
      end

      bsd_special = %w(
        include undef error warning if else elif endif for endfor
      )

      gnu_special = %w(
        ifeq ifneq ifdef ifndef else endif include -include define endef :
      )

      line = /(?:\\.|\\\n|[^\\\n])*/m

      def initialize(opts={})
        super
        @shell = Shell.new(opts)
      end

      start { @shell.reset! }

      state :root do
        rule /\s+/, 'Text'

        rule /#.*?\n/, 'Comment'

        rule /(export)(\s+)(?=[a-zA-Z0-9_\${}\t -]+\n)/ do
          group 'Keyword'; group 'Text'
          push :export
        end

        rule /export\s+/, 'Keyword'

        # assignment
        rule /([a-zA-Z0-9_${}.-]+)(\s*)([!?:+]?=)/m do |m|
          token 'Name.Variable', m[1]
          token 'Text', m[2]
          token 'Operator', m[3]
          push :shell_line
        end

        rule /"(\\\\|\\.|[^"\\])*"/, 'Literal.String.Double'
        rule /'(\\\\|\\.|[^'\\])*'/, 'Literal.String.Single'
        rule /([^\n:]+)(:+)([ \t]*)/ do
          group 'Name.Label'; group 'Operator'; group 'Text'
          push :block_header
        end
      end

      state :export do
        rule /[\w\${}-]/, 'Name.Variable'
        rule /\n/, 'Text', :pop!
        rule /\s+/, 'Text'
      end

      state :block_header do
        rule /[^,\\\n#]+/, 'Name.Function'
        rule /,/, 'Punctuation'
        rule /#.*?/, 'Comment'
        rule /\\\n/, 'Text'
        rule /\\./, 'Text'
        rule /\n/ do
          token 'Text'
          pop!; push :block_body
        end
      end

      state :block_body do
        rule /(\t[\t ]*)([@-]?)/ do |m|
          group 'Text'; group 'Punctuation'
          push :shell_line
        end

        rule(//) { @shell.reset!; pop! }
      end

      state :shell do
        # macro interpolation
        rule /\$\(\s*[a-z_]\w*\s*\)/i, 'Name.Variable'
        # $(shell ...)
        rule /(\$\()(\s*)(shell)(\s+)/m do
          group 'Name.Function'; group 'Text'
          group 'Name.Builtin'; group 'Text'
          push :shell_expr
        end

        rule(/\\./m) { delegate @shell }
        stop = /\$\(|\(|\)|\n|\\/
        rule(/.+?(?=#{stop})/m) { delegate @shell }
        rule(stop) { delegate @shell }
      end

      state :shell_expr do
        rule(/\(/) { delegate @shell; push }
        rule /\)/, 'Name.Variable', :pop!
        mixin :shell
      end

      state :shell_line do
        rule /\n/, 'Text', :pop!
        mixin :shell
      end
    end
  end
end
module Rouge
  module Lexers
    class Markdown < RegexLexer
      desc "Markdown, a light-weight markup language for authors"

      tag 'markdown'
      aliases 'md', 'mkd'
      filenames '*.markdown', '*.md', '*.mkd'
      mimetypes 'text/x-markdown'

      def html
        @html ||= HTML.new(options)
      end

      start { html.reset! }

      edot = /\\.|[^\\\n]/

      state :root do
        # YAML frontmatter
        rule(/\A(---\s*\n.*?\n?)^(---\s*$\n?)/m) { delegate YAML }

        rule /\\./, 'Literal.String.Escape'

        rule /^[\S ]+\n(?:---*)\n/, 'Generic.Heading'
        rule /^[\S ]+\n(?:===*)\n/, 'Generic.Subheading'

        rule /^#(?=[^#]).*?$/, 'Generic.Heading'
        rule /^##*.*?$/, 'Generic.Subheading'

        # TODO: syntax highlight the code block, github style
        rule /(\n[ \t]*)(```|~~~)(.*?)(\n.*?)(\2)/m do |m|
          sublexer = Lexer.find_fancy(m[3].strip, m[4])
          sublexer ||= Text.new(:token => 'Literal.String.Backtick')

          token 'Text', m[1]
          token 'Punctuation', m[2]
          token 'Name.Label', m[3]
          delegate sublexer, m[4]
          token 'Punctuation', m[5]
        end

        rule /\n\n((    |\t).*?\n|\n)+/, 'Literal.String.Backtick'

        rule /(`+)#{edot}*\1/, 'Literal.String.Backtick'

        # various uses of * are in order of precedence

        # line breaks
        rule /^(\s*[*]){3,}\s*$/, 'Punctuation'
        rule /^(\s*[-]){3,}\s*$/, 'Punctuation'

        # bulleted lists
        rule /^\s*[*+-](?=\s)/, 'Punctuation'

        # numbered lists
        rule /^\s*\d+\./, 'Punctuation'

        # blockquotes
        rule /^\s*>.*?$/, 'Generic.Traceback'

        # link references
        # [foo]: bar "baz"
        rule %r(^
          (\s*) # leading whitespace
          (\[) (#{edot}+?) (\]) # the reference
          (\s*) (:) # colon
        )x do
          group 'Text'
          group 'Punctuation'; group 'Literal.String.Symbol'; group 'Punctuation'
          group 'Text'; group 'Punctuation'

          push :title
          push :url
        end

        # links and images
        rule /(!?\[)(#{edot}+?)(\])/ do
          group 'Punctuation'
          group 'Name.Variable'
          group 'Punctuation'
          push :link
        end

        rule /[*][*]#{edot}*?[*][*]/, 'Generic.Strong'
        rule /__#{edot}*?__/, 'Generic.Strong'

        rule /[*]#{edot}*?[*]/, 'Generic.Emph'
        rule /_#{edot}*?_/, 'Generic.Emph'

        # Automatic links
        rule /<.*?@.+[.].+>/, 'Name.Variable'
        rule %r[<(https?|mailto|ftp)://#{edot}*?>], 'Name.Variable'


        rule /[^\\`\[*\n&<]+/, 'Text'

        # inline html
        rule(/&\S*;/) { delegate html }
        rule(/<#{edot}*?>/) { delegate html }
        rule /[&<]/, 'Text'

        rule /\n/, 'Text'
      end

      state :link do
        rule /(\[)(#{edot}*?)(\])/ do
          group 'Punctuation'
          group 'Literal.String.Symbol'
          group 'Punctuation'
          pop!
        end

        rule /[(]/ do
          token 'Punctuation'
          push :inline_title
          push :inline_url
        end

        rule /[ \t]+/, 'Text'

        rule(//) { pop! }
      end

      state :url do
        rule /[ \t]+/, 'Text'

        # the url
        rule /(<)(#{edot}*?)(>)/ do
          group 'Name.Tag'
          group 'Literal.String.Other'
          group 'Name.Tag'
          pop!
        end

        rule /\S+/, 'Literal.String.Other', :pop!
      end

      state :title do
        rule /"#{edot}*?"/, 'Name.Namespace'
        rule /'#{edot}*?'/, 'Name.Namespace'
        rule /[(]#{edot}*?[)]/, 'Name.Namespace'
        rule /\s*(?=["'()])/, 'Text'
        rule(//) { pop! }
      end

      state :inline_title do
        rule /[)]/, 'Punctuation', :pop!
        mixin :title
      end

      state :inline_url do
        rule /[^<\s)]+/, 'Literal.String.Other', :pop!
        rule /\s+/m, 'Text'
        mixin :url
      end
    end
  end
end
module Rouge
  module Lexers
    class Perl < RegexLexer
      desc "The Perl scripting language (perl.org)"

      tag 'perl'
      aliases 'pl'

      filenames '*.pl', '*.pm'
      mimetypes 'text/x-perl', 'application/x-perl'

      def self.analyze_text(text)
        return 1 if text.shebang? 'perl'
        return 0.9 if text.include? 'my $'
      end

      keywords = %w(
        case continue do else elsif for foreach if last my next our
        redo reset then unless until while use print new BEGIN CHECK
        INIT END return
      )

      builtins = %w(
        abs accept alarm atan2 bind binmode bless caller chdir chmod
        chomp chop chown chr chroot close closedir connect continue cos
        crypt dbmclose dbmopen defined delete die dump each endgrent
        endhostent endnetent endprotoent endpwent endservent eof eval
        exec exists exit exp fcntl fileno flock fork format formline getc
        getgrent getgrgid getgrnam gethostbyaddr gethostbyname gethostent
        getlogin getnetbyaddr getnetbyname getnetent getpeername
        getpgrp getppid getpriority getprotobyname getprotobynumber
        getprotoent getpwent getpwnam getpwuid getservbyname getservbyport
        getservent getsockname getsockopt glob gmtime goto grep hex
        import index int ioctl join keys kill last lc lcfirst length
        link listen local localtime log lstat map mkdir msgctl msgget
        msgrcv msgsnd my next no oct open opendir ord our pack package
        pipe pop pos printf prototype push quotemeta rand read readdir
        readline readlink readpipe recv redo ref rename require reverse
        rewinddir rindex rmdir scalar seek seekdir select semctl semget
        semop send setgrent sethostent setnetent setpgrp setpriority
        setprotoent setpwent setservent setsockopt shift shmctl shmget
        shmread shmwrite shutdown sin sleep socket socketpair sort splice
        split sprintf sqrt srand stat study substr symlink syscall sysopen
        sysread sysseek system syswrite tell telldir tie tied time times
        tr truncate uc ucfirst umask undef unlink unpack unshift untie
        utime values vec wait waitpid wantarray warn write
      )

      re_tok = 'Literal.String.Regex'

      state :balanced_regex do
        rule %r(/(\\\\|\\/|[^/])*/[egimosx]*)m, re_tok, :pop!
        rule %r(!(\\\\|\\!|[^!])*![egimosx]*)m, re_tok, :pop!
        rule %r(\\(\\\\|[^\\])*\\[egimosx]*)m, re_tok, :pop!
        rule %r({(\\\\|\\}|[^}])*}[egimosx]*), re_tok, :pop!
        rule %r(<(\\\\|\\>|[^>])*>[egimosx]*), re_tok, :pop!
        rule %r(\[(\\\\|\\\]|[^\]])*\][egimosx]*), re_tok, :pop!
        rule %r(\((\\\\|\\\)|[^\)])*\)[egimosx]*), re_tok, :pop!
        rule %r(@(\\\\|\\\@|[^\@])*@[egimosx]*), re_tok, :pop!
        rule %r(%(\\\\|\\\%|[^\%])*%[egimosx]*), re_tok, :pop!
        rule %r(\$(\\\\|\\\$|[^\$])*\$[egimosx]*), re_tok, :pop!
      end

      state :root do
        rule /#.*?$/, 'Comment.Single'
        rule /^=[a-zA-Z0-9]+\s+.*?\n=cut/, 'Comment.Multiline'
        rule /(?:#{keywords.join('|')})\b/, 'Keyword'

        rule /(format)(\s+)([a-zA-Z0-9_]+)(\s*)(=)(\s*\n)/ do
          group 'Keyword'; group 'Text'
          group 'Name'; group 'Text'
          group 'Punctuation'; group 'Text'

          push :format
        end

        rule /(?:eq|lt|gt|le|ge|ne|not|and|or|cmp)\b/, 'Operator.Word'

        # common delimiters
        rule %r(s/(\\\\|\\/|[^/])*/(\\\\|\\/|[^/])*/[egimosx]*), re_tok
        rule %r(s!(\\\\|\\!|[^!])*!(\\\\|\\!|[^!])*![egimosx]*), re_tok
        rule %r(s\\(\\\\|[^\\])*\\(\\\\|[^\\])*\\[egimosx]*), re_tok
        rule %r(s@(\\\\|\\@|[^@])*@(\\\\|\\@|[^@])*@[egimosx]*), re_tok
        rule %r(s%(\\\\|\\%|[^%])*%(\\\\|\\%|[^%])*%[egimosx]*), re_tok

        # balanced delimiters
        rule %r(s{(\\\\|\\}|[^}])*}\s*), re_tok, :balanced_regex
        rule %r(s<(\\\\|\\>|[^>])*>\s*), re_tok, :balanced_regex
        rule %r(s\[(\\\\|\\\]|[^\]])*\]\s*), re_tok, :balanced_regex
        rule %r(s\((\\\\|\\\)|[^\)])*\)\s*), re_tok, :balanced_regex

        rule %r(m?/(\\\\|\\/|[^/\n])*/[gcimosx]*), re_tok
        rule %r(m(?=[/!\\{<\[\(@%\$])), re_tok, :balanced_regex
        rule %r(((?<==~)|(?<=\())\s*/(\\\\|\\/|[^/])*/[gcimosx]*),
          re_tok, :balanced_regex

        rule /\s+/, 'Text'
        rule /(?:#{builtins.join('|')})\b/, 'Name.Builtin'
        rule /((__(DATA|DIE|WARN)__)|(STD(IN|OUT|ERR)))\b/,
          'Name.Builtin.Pseudo'

        rule /<<([\'"]?)([a-zA-Z_][a-zA-Z0-9_]*)\1;?\n.*?\n\2\n/m,
          'Literal.String'

        rule /__END__\b/, 'Comment.Preproc', :end_part
        rule /\$\^[ADEFHILMOPSTWX]/, 'Name.Variable.Global'
        rule /\$[\\"\[\]'&`+*.,;=%~?@$!<>(^\|\/-](?!\w)/, 'Name.Variable.Global'
        rule /[$@%#]+/, 'Name.Variable', :varname

        rule /0_?[0-7]+(_[0-7]+)*/, 'Literal.Number.Oct'
        rule /0x[0-9A-Fa-f]+(_[0-9A-Fa-f]+)*/, 'Literal.Number.Hex'
        rule /0b[01]+(_[01]+)*/, 'Literal.Number.Bin'
        rule /(\d*(_\d*)*\.\d+(_\d*)*|\d+(_\d*)*\.\d+(_\d*)*)(e[+-]?\d+)?/i,
          'Literal.Number.Float'
        rule /\d+(_\d*)*e[+-]?\d+(_\d*)*/i, 'Literal.Number.Float'
        rule /\d+(_\d+)*/, 'Literal.Number.Integer'

        rule /'(\\\\|\\'|[^'])*'/, 'Literal.String'
        rule /"(\\\\|\\"|[^"])*"/, 'Literal.String'
        rule /`(\\\\|\\`|[^`])*`/, 'Literal.String.Backtick'
        rule /<([^\s>]+)>/, re_tok
        rule /(q|qq|qw|qr|qx)\{/, 'Literal.String.Other', :cb_string
        rule /(q|qq|qw|qr|qx)\(/, 'Literal.String.Other', :rb_string
        rule /(q|qq|qw|qr|qx)\[/, 'Literal.String.Other', :sb_string
        rule /(q|qq|qw|qr|qx)</, 'Literal.String.Other', :lt_string
        rule /(q|qq|qw|qr|qx)([^a-zA-Z0-9])(.|\n)*?\2/, 'Literal.String.Other'

        rule /package\s+/, 'Keyword', :modulename
        rule /sub\s+/, 'Keyword', :funcname
        rule /\[\]|\*\*|::|<<|>>|>=|<=|<=>|={3}|!=|=~|!~|&&?|\|\||\.{1,3}/,
          'Operator'
        rule /[-+\/*%=<>&^\|!\\~]=?/, 'Operator'
        rule /[()\[\]:;,<>\/?{}]/, 'Punctuation'
        rule(/(?=\w)/) { push :name }
      end

      state :format do
        rule /\.\n/, 'Literal.String.Interpol', :pop!
        rule /.*?\n/, 'Literal.String.Interpol'
      end

      state :name_common do
        rule /\w+::/, 'Name.Namespace'
        rule /[\w:]+/, 'Name.Variable', :pop!
      end

      state :varname do
        rule /\s+/, 'Text'
        rule /\{/, 'Punctuation', :pop! # hash syntax
        rule /\)|,/, 'Punctuation', :pop! # arg specifier
        mixin :name_common
      end

      state :name do
        mixin :name_common
        rule /[A-Z_]+(?=[^a-zA-Z0-9_])/, 'Name.Constant', :pop!
        rule(/(?=\W)/) { pop! }
      end

      state :modulename do
        rule /[a-z_]\w*/i, 'Name.Namespace', :pop!
      end

      state :funcname do
        rule /[a-zA-Z_]\w*[!?]?/, 'Name.Function'
        rule /\s+/, 'Text'

        # argument declaration
        rule /(\([$@%]*\))(\s*)/ do
          group 'Punctuation'
          group 'Text'
        end

        rule /.*?{/, 'Punctuation', :pop!
        rule /;/, 'Punctuation', :pop!
      end

      [[:cb, '\{', '\}'],
       [:rb, '\(', '\)'],
       [:sb, '\[', '\]'],
       [:lt, '<',  '>']].each do |name, open, close|
        tok = 'Literal.String.Other'
        state :"#{name}_string" do
          rule /\\[#{open}#{close}\\]/, tok
          rule /\\/, tok
          rule(/#{open}/) { token tok; push }
          rule /#{close}/, tok, :pop!
          rule /[^#{open}#{close}\\]+/, tok
        end
      end

      state :end_part do
        # eat the rest of the stream
        rule /.+/m, 'Comment.Preproc', :pop!
      end
    end
  end
end
# automatically generated by `rake phpbuiltins`
module Rouge
  module Lexers
    class PHP
      def self.builtins
        @builtins ||= {}.tap do |b|
          b["Apache"] = Set.new %w(apache_child_terminate apache_child_terminate apache_get_modules apache_get_version apache_getenv apache_lookup_uri apache_note apache_request_headers apache_reset_timeout apache_response_headers apache_setenv getallheaders virtual apache_child_terminate)
          b["APC"] = Set.new %w(apc_add apc_add apc_bin_dump apc_bin_dumpfile apc_bin_load apc_bin_loadfile apc_cache_info apc_cas apc_clear_cache apc_compile_file apc_dec apc_define_constants apc_delete_file apc_delete apc_exists apc_fetch apc_inc apc_load_constants apc_sma_info apc_store apc_add)
          b["APD"] = Set.new %w(apd_breakpoint apd_breakpoint apd_callstack apd_clunk apd_continue apd_croak apd_dump_function_table apd_dump_persistent_resources apd_dump_regular_resources apd_echo apd_get_active_symbols apd_set_pprof_trace apd_set_session_trace_socket apd_set_session_trace apd_set_session override_function rename_function apd_breakpoint)
          b["Array"] = Set.new %w(array_change_key_case array_change_key_case array_chunk array_combine array_count_values array_diff_assoc array_diff_key array_diff_uassoc array_diff_ukey array_diff array_fill_keys array_fill array_filter array_flip array_intersect_assoc array_intersect_key array_intersect_uassoc array_intersect_ukey array_intersect array_key_exists array_keys array_map array_merge_recursive array_merge array_multisort array_pad array_pop array_product array_push array_rand array_reduce array_replace_recursive array_replace array_reverse array_search array_shift array_slice array_splice array_sum array_udiff_assoc array_udiff_uassoc array_udiff array_uintersect_assoc array_uintersect_uassoc array_uintersect array_unique array_unshift array_values array_walk_recursive array_walk array arsort asort compact count current each end extract in_array key krsort ksort list natcasesort natsort next pos prev range reset rsort shuffle sizeof sort uasort uksort usort array_change_key_case)
          b["BBCode"] = Set.new %w(bbcode_add_element bbcode_add_element bbcode_add_smiley bbcode_create bbcode_destroy bbcode_parse bbcode_set_arg_parser bbcode_set_flags bbcode_add_element)
          b["BC Math"] = Set.new %w(bcadd bcadd bccomp bcdiv bcmod bcmul bcpow bcpowmod bcscale bcsqrt bcsub bcadd)
          b["bcompiler"] = Set.new %w(bcompiler_load_exe bcompiler_load_exe bcompiler_load bcompiler_parse_class bcompiler_read bcompiler_write_class bcompiler_write_constant bcompiler_write_exe_footer bcompiler_write_file bcompiler_write_footer bcompiler_write_function bcompiler_write_functions_from_file bcompiler_write_header bcompiler_write_included_filename bcompiler_load_exe)
          b["Bzip2"] = Set.new %w(bzclose bzclose bzcompress bzdecompress bzerrno bzerror bzerrstr bzflush bzopen bzread bzwrite bzclose)
          b["Cairo"] = Set.new %w(cairo_create cairo_create cairo_font_face_get_type cairo_font_face_status cairo_font_options_create cairo_font_options_equal cairo_font_options_get_antialias cairo_font_options_get_hint_metrics cairo_font_options_get_hint_style cairo_font_options_get_subpixel_order cairo_font_options_hash cairo_font_options_merge cairo_font_options_set_antialias cairo_font_options_set_hint_metrics cairo_font_options_set_hint_style cairo_font_options_set_subpixel_order cairo_font_options_status cairo_format_stride_for_width cairo_image_surface_create_for_data cairo_image_surface_create_from_png cairo_image_surface_create cairo_image_surface_get_data cairo_image_surface_get_format cairo_image_surface_get_height cairo_image_surface_get_stride cairo_image_surface_get_width cairo_matrix_create_scale cairo_matrix_create_translate cairo_matrix_invert cairo_matrix_multiply cairo_matrix_rotate cairo_matrix_transform_distance cairo_matrix_transform_point cairo_matrix_translate cairo_pattern_add_color_stop_rgb cairo_pattern_add_color_stop_rgba cairo_pattern_create_for_surface cairo_pattern_create_linear cairo_pattern_create_radial cairo_pattern_create_rgb cairo_pattern_create_rgba cairo_pattern_get_color_stop_count cairo_pattern_get_color_stop_rgba cairo_pattern_get_extend cairo_pattern_get_filter cairo_pattern_get_linear_points cairo_pattern_get_matrix cairo_pattern_get_radial_circles cairo_pattern_get_rgba cairo_pattern_get_surface cairo_pattern_get_type cairo_pattern_set_extend cairo_pattern_set_filter cairo_pattern_set_matrix cairo_pattern_status cairo_pdf_surface_create cairo_pdf_surface_set_size cairo_ps_get_levels cairo_ps_level_to_string cairo_ps_surface_create cairo_ps_surface_dsc_begin_page_setup cairo_ps_surface_dsc_begin_setup cairo_ps_surface_dsc_comment cairo_ps_surface_get_eps cairo_ps_surface_restrict_to_level cairo_ps_surface_set_eps cairo_ps_surface_set_size cairo_scaled_font_create cairo_scaled_font_extents cairo_scaled_font_get_ctm cairo_scaled_font_get_font_face cairo_scaled_font_get_font_matrix cairo_scaled_font_get_font_options cairo_scaled_font_get_scale_matrix cairo_scaled_font_get_type cairo_scaled_font_glyph_extents cairo_scaled_font_status cairo_scaled_font_text_extents cairo_surface_copy_page cairo_surface_create_similar cairo_surface_finish cairo_surface_flush cairo_surface_get_content cairo_surface_get_device_offset cairo_surface_get_font_options cairo_surface_get_type cairo_surface_mark_dirty_rectangle cairo_surface_mark_dirty cairo_surface_set_device_offset cairo_surface_set_fallback_resolution cairo_surface_show_page cairo_surface_status cairo_surface_write_to_png cairo_svg_surface_create cairo_svg_surface_restrict_to_version cairo_svg_version_to_string cairo_create)
          b["Calendar"] = Set.new %w(cal_days_in_month cal_days_in_month cal_from_jd cal_info cal_to_jd easter_date easter_days FrenchToJD GregorianToJD JDDayOfWeek JDMonthName JDToFrench JDToGregorian jdtojewish JDToJulian jdtounix JewishToJD JulianToJD unixtojd cal_days_in_month)
          b["chdb"] = Set.new %w(chdb_create chdb_create chdb_create)
          b["Classkit"] = Set.new %w(classkit_import classkit_import classkit_method_add classkit_method_copy classkit_method_redefine classkit_method_remove classkit_method_rename classkit_import)
          b["Classes/Object"] = Set.new %w(__autoload __autoload call_user_method_array call_user_method class_alias class_exists get_called_class get_class_methods get_class_vars get_class get_declared_classes get_declared_interfaces get_declared_traits get_object_vars get_parent_class interface_exists is_a is_subclass_of method_exists property_exists trait_exists __autoload)
          b["COM"] = Set.new %w(com_addref com_addref com_create_guid com_event_sink com_get_active_object com_get com_invoke com_isenum com_load_typelib com_load com_message_pump com_print_typeinfo com_propget com_propput com_propset com_release com_set variant_abs variant_add variant_and variant_cast variant_cat variant_cmp variant_date_from_timestamp variant_date_to_timestamp variant_div variant_eqv variant_fix variant_get_type variant_idiv variant_imp variant_int variant_mod variant_mul variant_neg variant_not variant_or variant_pow variant_round variant_set_type variant_set variant_sub variant_xor com_addref)
          b["Crack"] = Set.new %w(crack_check crack_check crack_closedict crack_getlastmessage crack_opendict crack_check)
          b["Ctype"] = Set.new %w(ctype_alnum ctype_alnum ctype_alpha ctype_cntrl ctype_digit ctype_graph ctype_lower ctype_print ctype_punct ctype_space ctype_upper ctype_xdigit ctype_alnum)
          b["CUBRID"] = Set.new %w(cubrid_bind cubrid_bind cubrid_close_prepare cubrid_close_request cubrid_col_get cubrid_col_size cubrid_column_names cubrid_column_types cubrid_commit cubrid_connect_with_url cubrid_connect cubrid_current_oid cubrid_disconnect cubrid_drop cubrid_error_code_facility cubrid_error_code cubrid_error_msg cubrid_execute cubrid_fetch cubrid_free_result cubrid_get_autocommit cubrid_get_charset cubrid_get_class_name cubrid_get_client_info cubrid_get_db_parameter cubrid_get_query_timeout cubrid_get_server_info cubrid_get cubrid_insert_id cubrid_is_instance cubrid_lob_close cubrid_lob_export cubrid_lob_get cubrid_lob_send cubrid_lob_size cubrid_lob2_bind cubrid_lob2_close cubrid_lob2_export cubrid_lob2_import cubrid_lob2_new cubrid_lob2_read cubrid_lob2_seek64 cubrid_lob2_seek cubrid_lob2_size64 cubrid_lob2_size cubrid_lob2_tell64 cubrid_lob2_tell cubrid_lob2_write cubrid_lock_read cubrid_lock_write cubrid_move_cursor cubrid_next_result cubrid_num_cols cubrid_num_rows cubrid_pconnect_with_url cubrid_pconnect cubrid_prepare cubrid_put cubrid_rollback cubrid_schema cubrid_seq_drop cubrid_seq_insert cubrid_seq_put cubrid_set_add cubrid_set_autocommit cubrid_set_db_parameter cubrid_set_drop cubrid_set_query_timeout cubrid_version cubrid_bind)
          b["cURL"] = Set.new %w(curl_close curl_close curl_copy_handle curl_errno curl_error curl_exec curl_getinfo curl_init curl_multi_add_handle curl_multi_close curl_multi_exec curl_multi_getcontent curl_multi_info_read curl_multi_init curl_multi_remove_handle curl_multi_select curl_setopt_array curl_setopt curl_version curl_close)
          b["Cyrus"] = Set.new %w(cyrus_authenticate cyrus_authenticate cyrus_bind cyrus_close cyrus_connect cyrus_query cyrus_unbind cyrus_authenticate)
          b["Date/Time"] = Set.new %w(checkdate checkdate date_add date_create_from_format date_create date_date_set date_default_timezone_get date_default_timezone_set date_diff date_format date_get_last_errors date_interval_create_from_date_string date_interval_format date_isodate_set date_modify date_offset_get date_parse_from_format date_parse date_sub date_sun_info date_sunrise date_sunset date_time_set date_timestamp_get date_timestamp_set date_timezone_get date_timezone_set date getdate gettimeofday gmdate gmmktime gmstrftime idate localtime microtime mktime strftime strptime strtotime time timezone_abbreviations_list timezone_identifiers_list timezone_location_get timezone_name_from_abbr timezone_name_get timezone_offset_get timezone_open timezone_transitions_get timezone_version_get checkdate)
          b["DBA"] = Set.new %w(dba_close dba_close dba_delete dba_exists dba_fetch dba_firstkey dba_handlers dba_insert dba_key_split dba_list dba_nextkey dba_open dba_optimize dba_popen dba_replace dba_sync dba_close)
          b["dBase"] = Set.new %w(dbase_add_record dbase_add_record dbase_close dbase_create dbase_delete_record dbase_get_header_info dbase_get_record_with_names dbase_get_record dbase_numfields dbase_numrecords dbase_open dbase_pack dbase_replace_record dbase_add_record)
          b["DB++"] = Set.new %w(dbplus_add dbplus_add dbplus_aql dbplus_chdir dbplus_close dbplus_curr dbplus_errcode dbplus_errno dbplus_find dbplus_first dbplus_flush dbplus_freealllocks dbplus_freelock dbplus_freerlocks dbplus_getlock dbplus_getunique dbplus_info dbplus_last dbplus_lockrel dbplus_next dbplus_open dbplus_prev dbplus_rchperm dbplus_rcreate dbplus_rcrtexact dbplus_rcrtlike dbplus_resolve dbplus_restorepos dbplus_rkeys dbplus_ropen dbplus_rquery dbplus_rrename dbplus_rsecindex dbplus_runlink dbplus_rzap dbplus_savepos dbplus_setindex dbplus_setindexbynumber dbplus_sql dbplus_tcl dbplus_tremove dbplus_undo dbplus_undoprepare dbplus_unlockrel dbplus_unselect dbplus_update dbplus_xlockrel dbplus_xunlockrel dbplus_add)
          b["dbx"] = Set.new %w(dbx_close dbx_close dbx_compare dbx_connect dbx_error dbx_escape_string dbx_fetch_row dbx_query dbx_sort dbx_close)
          b["Direct IO"] = Set.new %w(dio_close dio_close dio_fcntl dio_open dio_read dio_seek dio_stat dio_tcsetattr dio_truncate dio_write dio_close)
          b["Directory"] = Set.new %w(chdir chdir chroot closedir dir getcwd opendir readdir rewinddir scandir chdir)
          b["DOM"] = Set.new %w(dom_import_simplexml dom_import_simplexml dom_import_simplexml)
          b[".NET"] = Set.new %w(dotnet_load dotnet_load dotnet_load)
          b["Eio"] = Set.new %w(eio_busy eio_busy eio_cancel eio_chmod eio_chown eio_close eio_custom eio_dup2 eio_event_loop eio_fallocate eio_fchmod eio_fchown eio_fdatasync eio_fstat eio_fstatvfs eio_fsync eio_ftruncate eio_futime eio_get_event_stream eio_get_last_error eio_grp_add eio_grp_cancel eio_grp_limit eio_grp eio_init eio_link eio_lstat eio_mkdir eio_mknod eio_nop eio_npending eio_nready eio_nreqs eio_nthreads eio_open eio_poll eio_read eio_readahead eio_readdir eio_readlink eio_realpath eio_rename eio_rmdir eio_seek eio_sendfile eio_set_max_idle eio_set_max_parallel eio_set_max_poll_reqs eio_set_max_poll_time eio_set_min_parallel eio_stat eio_statvfs eio_symlink eio_sync_file_range eio_sync eio_syncfs eio_truncate eio_unlink eio_utime eio_write eio_busy)
          b["Enchant"] = Set.new %w(enchant_broker_describe enchant_broker_describe enchant_broker_dict_exists enchant_broker_free_dict enchant_broker_free enchant_broker_get_error enchant_broker_init enchant_broker_list_dicts enchant_broker_request_dict enchant_broker_request_pwl_dict enchant_broker_set_ordering enchant_dict_add_to_personal enchant_dict_add_to_session enchant_dict_check enchant_dict_describe enchant_dict_get_error enchant_dict_is_in_session enchant_dict_quick_check enchant_dict_store_replacement enchant_dict_suggest enchant_broker_describe)
          b["Error Handling"] = Set.new %w(debug_backtrace debug_backtrace debug_print_backtrace error_get_last error_log error_reporting restore_error_handler restore_exception_handler set_error_handler set_exception_handler trigger_error user_error debug_backtrace)
          b["Program execution"] = Set.new %w(escapeshellarg escapeshellarg escapeshellcmd exec passthru proc_close proc_get_status proc_nice proc_open proc_terminate shell_exec system escapeshellarg)
          b["Exif"] = Set.new %w(exif_imagetype exif_imagetype exif_read_data exif_tagname exif_thumbnail read_exif_data exif_imagetype)
          b["Expect"] = Set.new %w(expect_expectl expect_expectl expect_popen expect_expectl)
          b["FAM"] = Set.new %w(fam_cancel_monitor fam_cancel_monitor fam_close fam_monitor_collection fam_monitor_directory fam_monitor_file fam_next_event fam_open fam_pending fam_resume_monitor fam_suspend_monitor fam_cancel_monitor)
          b["FrontBase"] = Set.new %w(fbsql_affected_rows fbsql_affected_rows fbsql_autocommit fbsql_blob_size fbsql_change_user fbsql_clob_size fbsql_close fbsql_commit fbsql_connect fbsql_create_blob fbsql_create_clob fbsql_create_db fbsql_data_seek fbsql_database_password fbsql_database fbsql_db_query fbsql_db_status fbsql_drop_db fbsql_errno fbsql_error fbsql_fetch_array fbsql_fetch_assoc fbsql_fetch_field fbsql_fetch_lengths fbsql_fetch_object fbsql_fetch_row fbsql_field_flags fbsql_field_len fbsql_field_name fbsql_field_seek fbsql_field_table fbsql_field_type fbsql_free_result fbsql_get_autostart_info fbsql_hostname fbsql_insert_id fbsql_list_dbs fbsql_list_fields fbsql_list_tables fbsql_next_result fbsql_num_fields fbsql_num_rows fbsql_password fbsql_pconnect fbsql_query fbsql_read_blob fbsql_read_clob fbsql_result fbsql_rollback fbsql_rows_fetched fbsql_select_db fbsql_set_characterset fbsql_set_lob_mode fbsql_set_password fbsql_set_transaction fbsql_start_db fbsql_stop_db fbsql_table_name fbsql_tablename fbsql_username fbsql_warnings fbsql_affected_rows)
          b["FDF"] = Set.new %w(fdf_add_doc_javascript fdf_add_doc_javascript fdf_add_template fdf_close fdf_create fdf_enum_values fdf_errno fdf_error fdf_get_ap fdf_get_attachment fdf_get_encoding fdf_get_file fdf_get_flags fdf_get_opt fdf_get_status fdf_get_value fdf_get_version fdf_header fdf_next_field_name fdf_open_string fdf_open fdf_remove_item fdf_save_string fdf_save fdf_set_ap fdf_set_encoding fdf_set_file fdf_set_flags fdf_set_javascript_action fdf_set_on_import_javascript fdf_set_opt fdf_set_status fdf_set_submit_form_action fdf_set_target_frame fdf_set_value fdf_set_version fdf_add_doc_javascript)
          b["Fileinfo"] = Set.new %w(finfo_buffer finfo_buffer finfo_close finfo_file finfo_open finfo_set_flags mime_content_type finfo_buffer)
          b["filePro"] = Set.new %w(filepro_fieldcount filepro_fieldcount filepro_fieldname filepro_fieldtype filepro_fieldwidth filepro_retrieve filepro_rowcount filepro filepro_fieldcount)
          b["Filesystem"] = Set.new %w(basename basename chgrp chmod chown clearstatcache copy delete dirname disk_free_space disk_total_space diskfreespace fclose feof fflush fgetc fgetcsv fgets fgetss file_exists file_get_contents file_put_contents file fileatime filectime filegroup fileinode filemtime fileowner fileperms filesize filetype flock fnmatch fopen fpassthru fputcsv fputs fread fscanf fseek fstat ftell ftruncate fwrite glob is_dir is_executable is_file is_link is_readable is_uploaded_file is_writable is_writeable lchgrp lchown link linkinfo lstat mkdir move_uploaded_file parse_ini_file parse_ini_string pathinfo pclose popen readfile readlink realpath_cache_get realpath_cache_size realpath rename rewind rmdir set_file_buffer stat symlink tempnam tmpfile touch umask unlink basename)
          b["Filter"] = Set.new %w(filter_has_var filter_has_var filter_id filter_input_array filter_input filter_list filter_var_array filter_var filter_has_var)
          b["FriBiDi"] = Set.new %w(fribidi_log2vis fribidi_log2vis fribidi_log2vis)
          b["FTP"] = Set.new %w(ftp_alloc ftp_alloc ftp_cdup ftp_chdir ftp_chmod ftp_close ftp_connect ftp_delete ftp_exec ftp_fget ftp_fput ftp_get_option ftp_get ftp_login ftp_mdtm ftp_mkdir ftp_nb_continue ftp_nb_fget ftp_nb_fput ftp_nb_get ftp_nb_put ftp_nlist ftp_pasv ftp_put ftp_pwd ftp_quit ftp_raw ftp_rawlist ftp_rename ftp_rmdir ftp_set_option ftp_site ftp_size ftp_ssl_connect ftp_systype ftp_alloc)
          b["Function handling"] = Set.new %w(call_user_func_array call_user_func_array call_user_func create_function forward_static_call_array forward_static_call func_get_arg func_get_args func_num_args function_exists get_defined_functions register_shutdown_function register_tick_function unregister_tick_function call_user_func_array)
          b["GeoIP"] = Set.new %w(geoip_continent_code_by_name geoip_continent_code_by_name geoip_country_code_by_name geoip_country_code3_by_name geoip_country_name_by_name geoip_database_info geoip_db_avail geoip_db_filename geoip_db_get_all_info geoip_id_by_name geoip_isp_by_name geoip_org_by_name geoip_record_by_name geoip_region_by_name geoip_region_name_by_code geoip_time_zone_by_country_and_region geoip_continent_code_by_name)
          b["Gettext"] = Set.new %w(bind_textdomain_codeset bind_textdomain_codeset bindtextdomain dcgettext dcngettext dgettext dngettext gettext ngettext textdomain bind_textdomain_codeset)
          b["GMP"] = Set.new %w(gmp_abs gmp_abs gmp_add gmp_and gmp_clrbit gmp_cmp gmp_com gmp_div_q gmp_div_qr gmp_div_r gmp_div gmp_divexact gmp_fact gmp_gcd gmp_gcdext gmp_hamdist gmp_init gmp_intval gmp_invert gmp_jacobi gmp_legendre gmp_mod gmp_mul gmp_neg gmp_nextprime gmp_or gmp_perfect_square gmp_popcount gmp_pow gmp_powm gmp_prob_prime gmp_random gmp_scan0 gmp_scan1 gmp_setbit gmp_sign gmp_sqrt gmp_sqrtrem gmp_strval gmp_sub gmp_testbit gmp_xor gmp_abs)
          b["GnuPG"] = Set.new %w(gnupg_adddecryptkey gnupg_adddecryptkey gnupg_addencryptkey gnupg_addsignkey gnupg_cleardecryptkeys gnupg_clearencryptkeys gnupg_clearsignkeys gnupg_decrypt gnupg_decryptverify gnupg_encrypt gnupg_encryptsign gnupg_export gnupg_geterror gnupg_getprotocol gnupg_import gnupg_init gnupg_keyinfo gnupg_setarmor gnupg_seterrormode gnupg_setsignmode gnupg_sign gnupg_verify gnupg_adddecryptkey)
          b["Gupnp"] = Set.new %w(gupnp_context_get_host_ip gupnp_context_get_host_ip gupnp_context_get_port gupnp_context_get_subscription_timeout gupnp_context_host_path gupnp_context_new gupnp_context_set_subscription_timeout gupnp_context_timeout_add gupnp_context_unhost_path gupnp_control_point_browse_start gupnp_control_point_browse_stop gupnp_control_point_callback_set gupnp_control_point_new gupnp_device_action_callback_set gupnp_device_info_get_service gupnp_device_info_get gupnp_root_device_get_available gupnp_root_device_get_relative_location gupnp_root_device_new gupnp_root_device_set_available gupnp_root_device_start gupnp_root_device_stop gupnp_service_action_get gupnp_service_action_return_error gupnp_service_action_return gupnp_service_action_set gupnp_service_freeze_notify gupnp_service_info_get_introspection gupnp_service_info_get gupnp_service_introspection_get_state_variable gupnp_service_notify gupnp_service_proxy_action_get gupnp_service_proxy_action_set gupnp_service_proxy_add_notify gupnp_service_proxy_callback_set gupnp_service_proxy_get_subscribed gupnp_service_proxy_remove_notify gupnp_service_proxy_set_subscribed gupnp_service_thaw_notify gupnp_context_get_host_ip)
          b["Hash"] = Set.new %w(hash_algos hash_algos hash_copy hash_file hash_final hash_hmac_file hash_hmac hash_init hash_pbkdf2 hash_update_file hash_update_stream hash_update hash hash_algos)
          b["HTTP"] = Set.new %w(http_cache_etag http_cache_etag http_cache_last_modified http_chunked_decode http_deflate http_inflate http_build_cookie http_date http_get_request_body_stream http_get_request_body http_get_request_headers http_match_etag http_match_modified http_match_request_header http_support http_negotiate_charset http_negotiate_content_type http_negotiate_language ob_deflatehandler ob_etaghandler ob_inflatehandler http_parse_cookie http_parse_headers http_parse_message http_parse_params http_persistent_handles_clean http_persistent_handles_count http_persistent_handles_ident http_get http_head http_post_data http_post_fields http_put_data http_put_file http_put_stream http_request_body_encode http_request_method_exists http_request_method_name http_request_method_register http_request_method_unregister http_request http_redirect http_send_content_disposition http_send_content_type http_send_data http_send_file http_send_last_modified http_send_status http_send_stream http_throttle http_build_str http_build_url http_cache_etag)
          b["Hyperwave"] = Set.new %w(hw_Array2Objrec hw_Array2Objrec hw_changeobject hw_Children hw_ChildrenObj hw_Close hw_Connect hw_connection_info hw_cp hw_Deleteobject hw_DocByAnchor hw_DocByAnchorObj hw_Document_Attributes hw_Document_BodyTag hw_Document_Content hw_Document_SetContent hw_Document_Size hw_dummy hw_EditText hw_Error hw_ErrorMsg hw_Free_Document hw_GetAnchors hw_GetAnchorsObj hw_GetAndLock hw_GetChildColl hw_GetChildCollObj hw_GetChildDocColl hw_GetChildDocCollObj hw_GetObject hw_GetObjectByQuery hw_GetObjectByQueryColl hw_GetObjectByQueryCollObj hw_GetObjectByQueryObj hw_GetParents hw_GetParentsObj hw_getrellink hw_GetRemote hw_getremotechildren hw_GetSrcByDestObj hw_GetText hw_getusername hw_Identify hw_InCollections hw_Info hw_InsColl hw_InsDoc hw_insertanchors hw_InsertDocument hw_InsertObject hw_mapid hw_Modifyobject hw_mv hw_New_Document hw_objrec2array hw_Output_Document hw_pConnect hw_PipeDocument hw_Root hw_setlinkroot hw_stat hw_Unlock hw_Who hw_Array2Objrec)
          b["Hyperwave API"] = Set.new %w(hwapi_attribute_new hwapi_content_new hwapi_hgcsp hwapi_object_new)
          b["Firebird/InterBase"] = Set.new %w(ibase_add_user ibase_add_user ibase_affected_rows ibase_backup ibase_blob_add ibase_blob_cancel ibase_blob_close ibase_blob_create ibase_blob_echo ibase_blob_get ibase_blob_import ibase_blob_info ibase_blob_open ibase_close ibase_commit_ret ibase_commit ibase_connect ibase_db_info ibase_delete_user ibase_drop_db ibase_errcode ibase_errmsg ibase_execute ibase_fetch_assoc ibase_fetch_object ibase_fetch_row ibase_field_info ibase_free_event_handler ibase_free_query ibase_free_result ibase_gen_id ibase_maintain_db ibase_modify_user ibase_name_result ibase_num_fields ibase_num_params ibase_param_info ibase_pconnect ibase_prepare ibase_query ibase_restore ibase_rollback_ret ibase_rollback ibase_server_info ibase_service_attach ibase_service_detach ibase_set_event_handler ibase_timefmt ibase_trans ibase_wait_event ibase_add_user)
          b["IBM DB2"] = Set.new %w(db2_autocommit db2_autocommit db2_bind_param db2_client_info db2_close db2_column_privileges db2_columns db2_commit db2_conn_error db2_conn_errormsg db2_connect db2_cursor_type db2_escape_string db2_exec db2_execute db2_fetch_array db2_fetch_assoc db2_fetch_both db2_fetch_object db2_fetch_row db2_field_display_size db2_field_name db2_field_num db2_field_precision db2_field_scale db2_field_type db2_field_width db2_foreign_keys db2_free_result db2_free_stmt db2_get_option db2_last_insert_id db2_lob_read db2_next_result db2_num_fields db2_num_rows db2_pclose db2_pconnect db2_prepare db2_primary_keys db2_procedure_columns db2_procedures db2_result db2_rollback db2_server_info db2_set_option db2_special_columns db2_statistics db2_stmt_error db2_stmt_errormsg db2_table_privileges db2_tables db2_autocommit)
          b["iconv"] = Set.new %w(iconv_get_encoding iconv_get_encoding iconv_mime_decode_headers iconv_mime_decode iconv_mime_encode iconv_set_encoding iconv_strlen iconv_strpos iconv_strrpos iconv_substr iconv ob_iconv_handler iconv_get_encoding)
          b["ID3"] = Set.new %w(id3_get_frame_long_name id3_get_frame_long_name id3_get_frame_short_name id3_get_genre_id id3_get_genre_list id3_get_genre_name id3_get_tag id3_get_version id3_remove_tag id3_set_tag id3_get_frame_long_name)
          b["Informix"] = Set.new %w(ifx_affected_rows ifx_affected_rows ifx_blobinfile_mode ifx_byteasvarchar ifx_close ifx_connect ifx_copy_blob ifx_create_blob ifx_create_char ifx_do ifx_error ifx_errormsg ifx_fetch_row ifx_fieldproperties ifx_fieldtypes ifx_free_blob ifx_free_char ifx_free_result ifx_get_blob ifx_get_char ifx_getsqlca ifx_htmltbl_result ifx_nullformat ifx_num_fields ifx_num_rows ifx_pconnect ifx_prepare ifx_query ifx_textasvarchar ifx_update_blob ifx_update_char ifxus_close_slob ifxus_create_slob ifxus_free_slob ifxus_open_slob ifxus_read_slob ifxus_seek_slob ifxus_tell_slob ifxus_write_slob ifx_affected_rows)
          b["IIS"] = Set.new %w(iis_add_server iis_add_server iis_get_dir_security iis_get_script_map iis_get_server_by_comment iis_get_server_by_path iis_get_server_rights iis_get_service_state iis_remove_server iis_set_app_settings iis_set_dir_security iis_set_script_map iis_set_server_rights iis_start_server iis_start_service iis_stop_server iis_stop_service iis_add_server)
          b["GD and Image"] = Set.new %w(gd_info gd_info getimagesize getimagesizefromstring image_type_to_extension image_type_to_mime_type image2wbmp imagealphablending imageantialias imagearc imagechar imagecharup imagecolorallocate imagecolorallocatealpha imagecolorat imagecolorclosest imagecolorclosestalpha imagecolorclosesthwb imagecolordeallocate imagecolorexact imagecolorexactalpha imagecolormatch imagecolorresolve imagecolorresolvealpha imagecolorset imagecolorsforindex imagecolorstotal imagecolortransparent imageconvolution imagecopy imagecopymerge imagecopymergegray imagecopyresampled imagecopyresized imagecreate imagecreatefromgd2 imagecreatefromgd2part imagecreatefromgd imagecreatefromgif imagecreatefromjpeg imagecreatefrompng imagecreatefromstring imagecreatefromwbmp imagecreatefromxbm imagecreatefromxpm imagecreatetruecolor imagedashedline imagedestroy imageellipse imagefill imagefilledarc imagefilledellipse imagefilledpolygon imagefilledrectangle imagefilltoborder imagefilter imagefontheight imagefontwidth imageftbbox imagefttext imagegammacorrect imagegd2 imagegd imagegif imagegrabscreen imagegrabwindow imageinterlace imageistruecolor imagejpeg imagelayereffect imageline imageloadfont imagepalettecopy imagepng imagepolygon imagepsbbox imagepsencodefont imagepsextendfont imagepsfreefont imagepsloadfont imagepsslantfont imagepstext imagerectangle imagerotate imagesavealpha imagesetbrush imagesetpixel imagesetstyle imagesetthickness imagesettile imagestring imagestringup imagesx imagesy imagetruecolortopalette imagettfbbox imagettftext imagetypes imagewbmp imagexbm iptcembed iptcparse jpeg2wbmp png2wbmp gd_info)
          b["IMAP"] = Set.new %w(imap_8bit imap_8bit imap_alerts imap_append imap_base64 imap_binary imap_body imap_bodystruct imap_check imap_clearflag_full imap_close imap_create imap_createmailbox imap_delete imap_deletemailbox imap_errors imap_expunge imap_fetch_overview imap_fetchbody imap_fetchheader imap_fetchmime imap_fetchstructure imap_fetchtext imap_gc imap_get_quota imap_get_quotaroot imap_getacl imap_getmailboxes imap_getsubscribed imap_header imap_headerinfo imap_headers imap_last_error imap_list imap_listmailbox imap_listscan imap_listsubscribed imap_lsub imap_mail_compose imap_mail_copy imap_mail_move imap_mail imap_mailboxmsginfo imap_mime_header_decode imap_msgno imap_num_msg imap_num_recent imap_open imap_ping imap_qprint imap_rename imap_renamemailbox imap_reopen imap_rfc822_parse_adrlist imap_rfc822_parse_headers imap_rfc822_write_address imap_savebody imap_scan imap_scanmailbox imap_search imap_set_quota imap_setacl imap_setflag_full imap_sort imap_status imap_subscribe imap_thread imap_timeout imap_uid imap_undelete imap_unsubscribe imap_utf7_decode imap_utf7_encode imap_utf8 imap_8bit)
          b["inclued"] = Set.new %w(inclued_get_data inclued_get_data inclued_get_data)
          b["PHP Options/Info"] = Set.new %w(assert_options assert_options assert dl extension_loaded gc_collect_cycles gc_disable gc_enable gc_enabled get_cfg_var get_current_user get_defined_constants get_extension_funcs get_include_path get_included_files get_loaded_extensions get_magic_quotes_gpc get_magic_quotes_runtime get_required_files getenv getlastmod getmygid getmyinode getmypid getmyuid getopt getrusage ini_alter ini_get_all ini_get ini_restore ini_set magic_quotes_runtime main memory_get_peak_usage memory_get_usage php_ini_loaded_file php_ini_scanned_files php_logo_guid php_sapi_name php_uname phpcredits phpinfo phpversion putenv restore_include_path set_include_path set_magic_quotes_runtime set_time_limit sys_get_temp_dir version_compare zend_logo_guid zend_thread_id zend_version assert_options)
          b["Ingres"] = Set.new %w(ingres_autocommit_state ingres_autocommit_state ingres_autocommit ingres_charset ingres_close ingres_commit ingres_connect ingres_cursor ingres_errno ingres_error ingres_errsqlstate ingres_escape_string ingres_execute ingres_fetch_array ingres_fetch_assoc ingres_fetch_object ingres_fetch_proc_return ingres_fetch_row ingres_field_length ingres_field_name ingres_field_nullable ingres_field_precision ingres_field_scale ingres_field_type ingres_free_result ingres_next_error ingres_num_fields ingres_num_rows ingres_pconnect ingres_prepare ingres_query ingres_result_seek ingres_rollback ingres_set_environment ingres_unbuffered_query ingres_autocommit_state)
          b["Inotify"] = Set.new %w(inotify_add_watch inotify_add_watch inotify_init inotify_queue_len inotify_read inotify_rm_watch inotify_add_watch)
          b["Grapheme"] = Set.new %w(grapheme_extract grapheme_extract grapheme_stripos grapheme_stristr grapheme_strlen grapheme_strpos grapheme_strripos grapheme_strrpos grapheme_strstr grapheme_substr grapheme_extract)
          b["intl"] = Set.new %w(idn_to_utf8 intl_error_name intl_error_name intl_get_error_code intl_get_error_message intl_is_failure idn_to_utf8 intl_error_name)
          b["IDN"] = Set.new %w(grapheme_substr idn_to_ascii idn_to_ascii idn_to_unicode idn_to_utf8 grapheme_substr idn_to_ascii)
          b["Java"] = Set.new %w(java_last_exception_clear java_last_exception_clear java_last_exception_get java_last_exception_clear)
          b["JSON"] = Set.new %w(json_decode json_decode json_encode json_last_error json_decode)
          b["Judy"] = Set.new %w(judy_type judy_type judy_version judy_type)
          b["KADM5"] = Set.new %w(kadm5_chpass_principal kadm5_chpass_principal kadm5_create_principal kadm5_delete_principal kadm5_destroy kadm5_flush kadm5_get_policies kadm5_get_principal kadm5_get_principals kadm5_init_with_password kadm5_modify_principal kadm5_chpass_principal)
          b["LDAP"] = Set.new %w(ldap_8859_to_t61 ldap_8859_to_t61 ldap_add ldap_bind ldap_close ldap_compare ldap_connect ldap_control_paged_result_response ldap_control_paged_result ldap_count_entries ldap_delete ldap_dn2ufn ldap_err2str ldap_errno ldap_error ldap_explode_dn ldap_first_attribute ldap_first_entry ldap_first_reference ldap_free_result ldap_get_attributes ldap_get_dn ldap_get_entries ldap_get_option ldap_get_values_len ldap_get_values ldap_list ldap_mod_add ldap_mod_del ldap_mod_replace ldap_modify ldap_next_attribute ldap_next_entry ldap_next_reference ldap_parse_reference ldap_parse_result ldap_read ldap_rename ldap_sasl_bind ldap_search ldap_set_option ldap_set_rebind_proc ldap_sort ldap_start_tls ldap_t61_to_8859 ldap_unbind ldap_8859_to_t61)
          b["Libevent"] = Set.new %w(event_add event_add event_base_free event_base_loop event_base_loopbreak event_base_loopexit event_base_new event_base_priority_init event_base_set event_buffer_base_set event_buffer_disable event_buffer_enable event_buffer_fd_set event_buffer_free event_buffer_new event_buffer_priority_set event_buffer_read event_buffer_set_callback event_buffer_timeout_set event_buffer_watermark_set event_buffer_write event_del event_free event_new event_set event_add)
          b["libxml"] = Set.new %w(libxml_clear_errors libxml_clear_errors libxml_disable_entity_loader libxml_get_errors libxml_get_last_error libxml_set_external_entity_loader libxml_set_streams_context libxml_use_internal_errors libxml_clear_errors)
          b["LZF"] = Set.new %w(lzf_compress lzf_compress lzf_decompress lzf_optimized_for lzf_compress)
          b["Mail"] = Set.new %w(ezmlm_hash ezmlm_hash mail ezmlm_hash)
          b["Mailparse"] = Set.new %w(mailparse_determine_best_xfer_encoding mailparse_determine_best_xfer_encoding mailparse_msg_create mailparse_msg_extract_part_file mailparse_msg_extract_part mailparse_msg_extract_whole_part_file mailparse_msg_free mailparse_msg_get_part_data mailparse_msg_get_part mailparse_msg_get_structure mailparse_msg_parse_file mailparse_msg_parse mailparse_rfc822_parse_addresses mailparse_stream_encode mailparse_uudecode_all mailparse_determine_best_xfer_encoding)
          b["Math"] = Set.new %w(abs abs acos acosh asin asinh atan2 atan atanh base_convert bindec ceil cos cosh decbin dechex decoct deg2rad exp expm1 floor fmod getrandmax hexdec hypot is_finite is_infinite is_nan lcg_value log10 log1p log max min mt_getrandmax mt_rand mt_srand octdec pi pow rad2deg rand round sin sinh sqrt srand tan tanh abs)
          b["MaxDB"] = Set.new %w(maxdb_affected_rows maxdb_affected_rows maxdb_autocommit maxdb_bind_param maxdb_bind_result maxdb_change_user maxdb_character_set_name maxdb_client_encoding maxdb_close_long_data maxdb_close maxdb_commit maxdb_connect_errno maxdb_connect_error maxdb_connect maxdb_data_seek maxdb_debug maxdb_disable_reads_from_master maxdb_disable_rpl_parse maxdb_dump_debug_info maxdb_embedded_connect maxdb_enable_reads_from_master maxdb_enable_rpl_parse maxdb_errno maxdb_error maxdb_escape_string maxdb_execute maxdb_fetch_array maxdb_fetch_assoc maxdb_fetch_field_direct maxdb_fetch_field maxdb_fetch_fields maxdb_fetch_lengths maxdb_fetch_object maxdb_fetch_row maxdb_fetch maxdb_field_count maxdb_field_seek maxdb_field_tell maxdb_free_result maxdb_get_client_info maxdb_get_client_version maxdb_get_host_info maxdb_get_metadata maxdb_get_proto_info maxdb_get_server_info maxdb_get_server_version maxdb_info maxdb_init maxdb_insert_id maxdb_kill maxdb_master_query maxdb_more_results maxdb_multi_query maxdb_next_result maxdb_num_fields maxdb_num_rows maxdb_options maxdb_param_count maxdb_ping maxdb_prepare maxdb_query maxdb_real_connect maxdb_real_escape_string maxdb_real_query maxdb_report maxdb_rollback maxdb_rpl_parse_enabled maxdb_rpl_probe maxdb_rpl_query_type maxdb_select_db maxdb_send_long_data maxdb_send_query maxdb_server_end maxdb_server_init maxdb_set_opt maxdb_sqlstate maxdb_ssl_set maxdb_stat maxdb_stmt_affected_rows maxdb_stmt_bind_param maxdb_stmt_bind_result maxdb_stmt_close_long_data maxdb_stmt_close maxdb_stmt_data_seek maxdb_stmt_errno maxdb_stmt_error maxdb_stmt_execute maxdb_stmt_fetch maxdb_stmt_free_result maxdb_stmt_init maxdb_stmt_num_rows maxdb_stmt_param_count maxdb_stmt_prepare maxdb_stmt_reset maxdb_stmt_result_metadata maxdb_stmt_send_long_data maxdb_stmt_sqlstate maxdb_stmt_store_result maxdb_store_result maxdb_thread_id maxdb_thread_safe maxdb_use_result maxdb_warning_count maxdb_affected_rows)
          b["Multibyte String"] = Set.new %w(mb_check_encoding mb_check_encoding mb_convert_case mb_convert_encoding mb_convert_kana mb_convert_variables mb_decode_mimeheader mb_decode_numericentity mb_detect_encoding mb_detect_order mb_encode_mimeheader mb_encode_numericentity mb_encoding_aliases mb_ereg_match mb_ereg_replace_callback mb_ereg_replace mb_ereg_search_getpos mb_ereg_search_getregs mb_ereg_search_init mb_ereg_search_pos mb_ereg_search_regs mb_ereg_search_setpos mb_ereg_search mb_ereg mb_eregi_replace mb_eregi mb_get_info mb_http_input mb_http_output mb_internal_encoding mb_language mb_list_encodings mb_output_handler mb_parse_str mb_preferred_mime_name mb_regex_encoding mb_regex_set_options mb_send_mail mb_split mb_strcut mb_strimwidth mb_stripos mb_stristr mb_strlen mb_strpos mb_strrchr mb_strrichr mb_strripos mb_strrpos mb_strstr mb_strtolower mb_strtoupper mb_strwidth mb_substitute_character mb_substr_count mb_substr mb_check_encoding)
          b["Mcrypt"] = Set.new %w(mcrypt_cbc mcrypt_cbc mcrypt_cfb mcrypt_create_iv mcrypt_decrypt mcrypt_ecb mcrypt_enc_get_algorithms_name mcrypt_enc_get_block_size mcrypt_enc_get_iv_size mcrypt_enc_get_key_size mcrypt_enc_get_modes_name mcrypt_enc_get_supported_key_sizes mcrypt_enc_is_block_algorithm_mode mcrypt_enc_is_block_algorithm mcrypt_enc_is_block_mode mcrypt_enc_self_test mcrypt_encrypt mcrypt_generic_deinit mcrypt_generic_end mcrypt_generic_init mcrypt_generic mcrypt_get_block_size mcrypt_get_cipher_name mcrypt_get_iv_size mcrypt_get_key_size mcrypt_list_algorithms mcrypt_list_modes mcrypt_module_close mcrypt_module_get_algo_block_size mcrypt_module_get_algo_key_size mcrypt_module_get_supported_key_sizes mcrypt_module_is_block_algorithm_mode mcrypt_module_is_block_algorithm mcrypt_module_is_block_mode mcrypt_module_open mcrypt_module_self_test mcrypt_ofb mdecrypt_generic mcrypt_cbc)
          b["MCVE"] = Set.new %w(m_checkstatus m_checkstatus m_completeauthorizations m_connect m_connectionerror m_deletetrans m_destroyconn m_destroyengine m_getcell m_getcellbynum m_getcommadelimited m_getheader m_initconn m_initengine m_iscommadelimited m_maxconntimeout m_monitor m_numcolumns m_numrows m_parsecommadelimited m_responsekeys m_responseparam m_returnstatus m_setblocking m_setdropfile m_setip m_setssl_cafile m_setssl_files m_setssl m_settimeout m_sslcert_gen_hash m_transactionssent m_transinqueue m_transkeyval m_transnew m_transsend m_uwait m_validateidentifier m_verifyconnection m_verifysslcert m_checkstatus)
          b["Memcache"] = Set.new %w(memcache_debug memcache_debug memcache_debug)
          b["Mhash"] = Set.new %w(mhash_count mhash_count mhash_get_block_size mhash_get_hash_name mhash_keygen_s2k mhash mhash_count)
          b["Ming"] = Set.new %w(ming_keypress ming_keypress ming_setcubicthreshold ming_setscale ming_setswfcompression ming_useconstants ming_useswfversion ming_keypress)
          b["Misc."] = Set.new %w(connection_aborted connection_aborted connection_status connection_timeout constant define defined die eval exit get_browser __halt_compiler highlight_file highlight_string ignore_user_abort pack php_check_syntax php_strip_whitespace show_source sleep sys_getloadavg time_nanosleep time_sleep_until uniqid unpack usleep connection_aborted)
          b["mnoGoSearch"] = Set.new %w(udm_add_search_limit udm_add_search_limit udm_alloc_agent_array udm_alloc_agent udm_api_version udm_cat_list udm_cat_path udm_check_charset udm_check_stored udm_clear_search_limits udm_close_stored udm_crc32 udm_errno udm_error udm_find udm_free_agent udm_free_ispell_data udm_free_res udm_get_doc_count udm_get_res_field udm_get_res_param udm_hash32 udm_load_ispell_data udm_open_stored udm_set_agent_param udm_add_search_limit)
          b["Mongo"] = Set.new %w(bson_decode bson_decode bson_encode bson_decode)
          b["mqseries"] = Set.new %w(mqseries_back mqseries_back mqseries_begin mqseries_close mqseries_cmit mqseries_conn mqseries_connx mqseries_disc mqseries_get mqseries_inq mqseries_open mqseries_put1 mqseries_put mqseries_set mqseries_strerror mqseries_back)
          b["Msession"] = Set.new %w(msession_connect msession_connect msession_count msession_create msession_destroy msession_disconnect msession_find msession_get_array msession_get_data msession_get msession_inc msession_list msession_listvar msession_lock msession_plugin msession_randstr msession_set_array msession_set_data msession_set msession_timeout msession_uniq msession_unlock msession_connect)
          b["mSQL"] = Set.new %w(msql_affected_rows msql_affected_rows msql_close msql_connect msql_create_db msql_createdb msql_data_seek msql_db_query msql_dbname msql_drop_db msql_error msql_fetch_array msql_fetch_field msql_fetch_object msql_fetch_row msql_field_flags msql_field_len msql_field_name msql_field_seek msql_field_table msql_field_type msql_fieldflags msql_fieldlen msql_fieldname msql_fieldtable msql_fieldtype msql_free_result msql_list_dbs msql_list_fields msql_list_tables msql_num_fields msql_num_rows msql_numfields msql_numrows msql_pconnect msql_query msql_regcase msql_result msql_select_db msql_tablename msql msql_affected_rows)
          b["Mssql"] = Set.new %w(mssql_bind mssql_bind mssql_close mssql_connect mssql_data_seek mssql_execute mssql_fetch_array mssql_fetch_assoc mssql_fetch_batch mssql_fetch_field mssql_fetch_object mssql_fetch_row mssql_field_length mssql_field_name mssql_field_seek mssql_field_type mssql_free_result mssql_free_statement mssql_get_last_message mssql_guid_string mssql_init mssql_min_error_severity mssql_min_message_severity mssql_next_result mssql_num_fields mssql_num_rows mssql_pconnect mssql_query mssql_result mssql_rows_affected mssql_select_db mssql_bind)
          b["MySQL"] = Set.new %w(mysql_affected_rows mysql_affected_rows mysql_client_encoding mysql_close mysql_connect mysql_create_db mysql_data_seek mysql_db_name mysql_db_query mysql_drop_db mysql_errno mysql_error mysql_escape_string mysql_fetch_array mysql_fetch_assoc mysql_fetch_field mysql_fetch_lengths mysql_fetch_object mysql_fetch_row mysql_field_flags mysql_field_len mysql_field_name mysql_field_seek mysql_field_table mysql_field_type mysql_free_result mysql_get_client_info mysql_get_host_info mysql_get_proto_info mysql_get_server_info mysql_info mysql_insert_id mysql_list_dbs mysql_list_fields mysql_list_processes mysql_list_tables mysql_num_fields mysql_num_rows mysql_pconnect mysql_ping mysql_query mysql_real_escape_string mysql_result mysql_select_db mysql_set_charset mysql_stat mysql_tablename mysql_thread_id mysql_unbuffered_query mysql_affected_rows)
          b["Aliases and deprecated Mysqli"] = Set.new %w(mysqli_bind_param mysqli_bind_param mysqli_bind_result mysqli_client_encoding mysqli_connect mysqli_disable_rpl_parse mysqli_enable_reads_from_master mysqli_enable_rpl_parse mysqli_escape_string mysqli_execute mysqli_fetch mysqli_get_cache_stats mysqli_get_metadata mysqli_master_query mysqli_param_count mysqli_report mysqli_rpl_parse_enabled mysqli_rpl_probe mysqli_send_long_data mysqli_set_opt mysqli_slave_query mysqli_bind_param)
          b["Mysqlnd_ms"] = Set.new %w(mysqlnd_ms_get_last_gtid mysqlnd_ms_get_last_gtid mysqlnd_ms_get_last_used_connection mysqlnd_ms_get_stats mysqlnd_ms_match_wild mysqlnd_ms_query_is_select mysqlnd_ms_set_qos mysqlnd_ms_set_user_pick_server mysqlnd_ms_get_last_gtid)
          b["mysqlnd_qc"] = Set.new %w(mysqlnd_qc_clear_cache mysqlnd_qc_clear_cache mysqlnd_qc_get_available_handlers mysqlnd_qc_get_cache_info mysqlnd_qc_get_core_stats mysqlnd_qc_get_normalized_query_trace_log mysqlnd_qc_get_query_trace_log mysqlnd_qc_set_cache_condition mysqlnd_qc_set_is_select mysqlnd_qc_set_storage_handler mysqlnd_qc_set_user_handlers mysqlnd_qc_clear_cache)
          b["Mysqlnd_uh"] = Set.new %w(mysqlnd_uh_convert_to_mysqlnd mysqlnd_uh_convert_to_mysqlnd mysqlnd_uh_set_connection_proxy mysqlnd_uh_set_statement_proxy mysqlnd_uh_convert_to_mysqlnd)
          b["Ncurses"] = Set.new %w(ncurses_addch ncurses_addch ncurses_addchnstr ncurses_addchstr ncurses_addnstr ncurses_addstr ncurses_assume_default_colors ncurses_attroff ncurses_attron ncurses_attrset ncurses_baudrate ncurses_beep ncurses_bkgd ncurses_bkgdset ncurses_border ncurses_bottom_panel ncurses_can_change_color ncurses_cbreak ncurses_clear ncurses_clrtobot ncurses_clrtoeol ncurses_color_content ncurses_color_set ncurses_curs_set ncurses_def_prog_mode ncurses_def_shell_mode ncurses_define_key ncurses_del_panel ncurses_delay_output ncurses_delch ncurses_deleteln ncurses_delwin ncurses_doupdate ncurses_echo ncurses_echochar ncurses_end ncurses_erase ncurses_erasechar ncurses_filter ncurses_flash ncurses_flushinp ncurses_getch ncurses_getmaxyx ncurses_getmouse ncurses_getyx ncurses_halfdelay ncurses_has_colors ncurses_has_ic ncurses_has_il ncurses_has_key ncurses_hide_panel ncurses_hline ncurses_inch ncurses_init_color ncurses_init_pair ncurses_init ncurses_insch ncurses_insdelln ncurses_insertln ncurses_insstr ncurses_instr ncurses_isendwin ncurses_keyok ncurses_keypad ncurses_killchar ncurses_longname ncurses_meta ncurses_mouse_trafo ncurses_mouseinterval ncurses_mousemask ncurses_move_panel ncurses_move ncurses_mvaddch ncurses_mvaddchnstr ncurses_mvaddchstr ncurses_mvaddnstr ncurses_mvaddstr ncurses_mvcur ncurses_mvdelch ncurses_mvgetch ncurses_mvhline ncurses_mvinch ncurses_mvvline ncurses_mvwaddstr ncurses_napms ncurses_new_panel ncurses_newpad ncurses_newwin ncurses_nl ncurses_nocbreak ncurses_noecho ncurses_nonl ncurses_noqiflush ncurses_noraw ncurses_pair_content ncurses_panel_above ncurses_panel_below ncurses_panel_window ncurses_pnoutrefresh ncurses_prefresh ncurses_putp ncurses_qiflush ncurses_raw ncurses_refresh ncurses_replace_panel ncurses_reset_prog_mode ncurses_reset_shell_mode ncurses_resetty ncurses_savetty ncurses_scr_dump ncurses_scr_init ncurses_scr_restore ncurses_scr_set ncurses_scrl ncurses_show_panel ncurses_slk_attr ncurses_slk_attroff ncurses_slk_attron ncurses_slk_attrset ncurses_slk_clear ncurses_slk_color ncurses_slk_init ncurses_slk_noutrefresh ncurses_slk_refresh ncurses_slk_restore ncurses_slk_set ncurses_slk_touch ncurses_standend ncurses_standout ncurses_start_color ncurses_termattrs ncurses_termname ncurses_timeout ncurses_top_panel ncurses_typeahead ncurses_ungetch ncurses_ungetmouse ncurses_update_panels ncurses_use_default_colors ncurses_use_env ncurses_use_extended_names ncurses_vidattr ncurses_vline ncurses_waddch ncurses_waddstr ncurses_wattroff ncurses_wattron ncurses_wattrset ncurses_wborder ncurses_wclear ncurses_wcolor_set ncurses_werase ncurses_wgetch ncurses_whline ncurses_wmouse_trafo ncurses_wmove ncurses_wnoutrefresh ncurses_wrefresh ncurses_wstandend ncurses_wstandout ncurses_wvline ncurses_addch)
          b["Gopher"] = Set.new %w(gopher_parsedir gopher_parsedir gopher_parsedir)
          b["Network"] = Set.new %w(checkdnsrr checkdnsrr closelog define_syslog_variables dns_check_record dns_get_mx dns_get_record fsockopen gethostbyaddr gethostbyname gethostbynamel gethostname getmxrr getprotobyname getprotobynumber getservbyname getservbyport header_register_callback header_remove header headers_list headers_sent http_response_code inet_ntop inet_pton ip2long long2ip openlog pfsockopen setcookie setrawcookie socket_get_status socket_set_blocking socket_set_timeout syslog checkdnsrr)
          b["Newt"] = Set.new %w(newt_bell newt_bell newt_button_bar newt_button newt_centered_window newt_checkbox_get_value newt_checkbox_set_flags newt_checkbox_set_value newt_checkbox_tree_add_item newt_checkbox_tree_find_item newt_checkbox_tree_get_current newt_checkbox_tree_get_entry_value newt_checkbox_tree_get_multi_selection newt_checkbox_tree_get_selection newt_checkbox_tree_multi newt_checkbox_tree_set_current newt_checkbox_tree_set_entry_value newt_checkbox_tree_set_entry newt_checkbox_tree_set_width newt_checkbox_tree newt_checkbox newt_clear_key_buffer newt_cls newt_compact_button newt_component_add_callback newt_component_takes_focus newt_create_grid newt_cursor_off newt_cursor_on newt_delay newt_draw_form newt_draw_root_text newt_entry_get_value newt_entry_set_filter newt_entry_set_flags newt_entry_set newt_entry newt_finished newt_form_add_component newt_form_add_components newt_form_add_hot_key newt_form_destroy newt_form_get_current newt_form_run newt_form_set_background newt_form_set_height newt_form_set_size newt_form_set_timer newt_form_set_width newt_form_watch_fd newt_form newt_get_screen_size newt_grid_add_components_to_form newt_grid_basic_window newt_grid_free newt_grid_get_size newt_grid_h_close_stacked newt_grid_h_stacked newt_grid_place newt_grid_set_field newt_grid_simple_window newt_grid_v_close_stacked newt_grid_v_stacked newt_grid_wrapped_window_at newt_grid_wrapped_window newt_init newt_label_set_text newt_label newt_listbox_append_entry newt_listbox_clear_selection newt_listbox_clear newt_listbox_delete_entry newt_listbox_get_current newt_listbox_get_selection newt_listbox_insert_entry newt_listbox_item_count newt_listbox_select_item newt_listbox_set_current_by_key newt_listbox_set_current newt_listbox_set_data newt_listbox_set_entry newt_listbox_set_width newt_listbox newt_listitem_get_data newt_listitem_set newt_listitem newt_open_window newt_pop_help_line newt_pop_window newt_push_help_line newt_radio_get_current newt_radiobutton newt_redraw_help_line newt_reflow_text newt_refresh newt_resize_screen newt_resume newt_run_form newt_scale_set newt_scale newt_scrollbar_set newt_set_help_callback newt_set_suspend_callback newt_suspend newt_textbox_get_num_lines newt_textbox_reflowed newt_textbox_set_height newt_textbox_set_text newt_textbox newt_vertical_scrollbar newt_wait_for_key newt_win_choice newt_win_entries newt_win_menu newt_win_message newt_win_messagev newt_win_ternary newt_bell)
          b["YP/NIS"] = Set.new %w(yp_all yp_all yp_cat yp_err_string yp_errno yp_first yp_get_default_domain yp_master yp_match yp_next yp_order yp_all)
          b["Lotus Notes"] = Set.new %w(notes_body notes_body notes_copy_db notes_create_db notes_create_note notes_drop_db notes_find_note notes_header_info notes_list_msgs notes_mark_read notes_mark_unread notes_nav_create notes_search notes_unread notes_version notes_body)
          b["NSAPI"] = Set.new %w(nsapi_request_headers nsapi_request_headers nsapi_response_headers nsapi_virtual nsapi_request_headers)
          b["OAuth"] = Set.new %w(oauth_get_sbs oauth_get_sbs oauth_urlencode oauth_get_sbs)
          b["Object Aggregation"] = Set.new %w(aggregate_info aggregate_info aggregate_methods_by_list aggregate_methods_by_regexp aggregate_methods aggregate_properties_by_list aggregate_properties_by_regexp aggregate_properties aggregate aggregation_info deaggregate aggregate_info)
          b["OCI8"] = Set.new %w(oci_bind_array_by_name oci_bind_by_name oci_cancel oci_client_version oci_close oci_commit oci_connect oci_define_by_name oci_error oci_execute oci_fetch_all oci_fetch_array oci_fetch_assoc oci_fetch_object oci_fetch_row oci_fetch oci_field_is_null oci_field_name oci_field_precision oci_field_scale oci_field_size oci_field_type_raw oci_field_type oci_free_statement oci_internal_debug oci_lob_copy oci_lob_is_equal oci_new_collection oci_new_connect oci_new_cursor oci_new_descriptor oci_num_fields oci_num_rows oci_parse oci_password_change oci_pconnect oci_result oci_rollback oci_server_version oci_set_action oci_set_client_identifier oci_set_client_info oci_set_edition oci_set_module_name oci_set_prefetch oci_statement_type)
          b["OpenAL"] = Set.new %w(openal_buffer_create openal_buffer_create openal_buffer_data openal_buffer_destroy openal_buffer_get openal_buffer_loadwav openal_context_create openal_context_current openal_context_destroy openal_context_process openal_context_suspend openal_device_close openal_device_open openal_listener_get openal_listener_set openal_source_create openal_source_destroy openal_source_get openal_source_pause openal_source_play openal_source_rewind openal_source_set openal_source_stop openal_stream openal_buffer_create)
          b["OpenSSL"] = Set.new %w(openssl_cipher_iv_length openssl_cipher_iv_length openssl_csr_export_to_file openssl_csr_export openssl_csr_get_public_key openssl_csr_get_subject openssl_csr_new openssl_csr_sign openssl_decrypt openssl_dh_compute_key openssl_digest openssl_encrypt openssl_error_string openssl_free_key openssl_get_cipher_methods openssl_get_md_methods openssl_get_privatekey openssl_get_publickey openssl_open openssl_pkcs12_export_to_file openssl_pkcs12_export openssl_pkcs12_read openssl_pkcs7_decrypt openssl_pkcs7_encrypt openssl_pkcs7_sign openssl_pkcs7_verify openssl_pkey_export_to_file openssl_pkey_export openssl_pkey_free openssl_pkey_get_details openssl_pkey_get_private openssl_pkey_get_public openssl_pkey_new openssl_private_decrypt openssl_private_encrypt openssl_public_decrypt openssl_public_encrypt openssl_random_pseudo_bytes openssl_seal openssl_sign openssl_verify openssl_x509_check_private_key openssl_x509_checkpurpose openssl_x509_export_to_file openssl_x509_export openssl_x509_free openssl_x509_parse openssl_x509_read openssl_cipher_iv_length)
          b["Output Control"] = Set.new %w(flush flush ob_clean ob_end_clean ob_end_flush ob_flush ob_get_clean ob_get_contents ob_get_flush ob_get_length ob_get_level ob_get_status ob_gzhandler ob_implicit_flush ob_list_handlers ob_start output_add_rewrite_var output_reset_rewrite_vars flush)
          b["Ovrimos SQL"] = Set.new %w(ovrimos_close ovrimos_close ovrimos_commit ovrimos_connect ovrimos_cursor ovrimos_exec ovrimos_execute ovrimos_fetch_into ovrimos_fetch_row ovrimos_field_len ovrimos_field_name ovrimos_field_num ovrimos_field_type ovrimos_free_result ovrimos_longreadlen ovrimos_num_fields ovrimos_num_rows ovrimos_prepare ovrimos_result_all ovrimos_result ovrimos_rollback ovrimos_close)
          b["Paradox"] = Set.new %w(px_close px_close px_create_fp px_date2string px_delete_record px_delete px_get_field px_get_info px_get_parameter px_get_record px_get_schema px_get_value px_insert_record px_new px_numfields px_numrecords px_open_fp px_put_record px_retrieve_record px_set_blob_file px_set_parameter px_set_tablename px_set_targetencoding px_set_value px_timestamp2string px_update_record px_close)
          b["Parsekit"] = Set.new %w(parsekit_compile_file parsekit_compile_file parsekit_compile_string parsekit_func_arginfo parsekit_compile_file)
          b["PCNTL"] = Set.new %w(pcntl_alarm pcntl_alarm pcntl_exec pcntl_fork pcntl_getpriority pcntl_setpriority pcntl_signal_dispatch pcntl_signal pcntl_sigprocmask pcntl_sigtimedwait pcntl_sigwaitinfo pcntl_wait pcntl_waitpid pcntl_wexitstatus pcntl_wifexited pcntl_wifsignaled pcntl_wifstopped pcntl_wstopsig pcntl_wtermsig pcntl_alarm)
          b["PCRE"] = Set.new %w(preg_filter preg_filter preg_grep preg_last_error preg_match_all preg_match preg_quote preg_replace_callback preg_replace preg_split preg_filter)
          b["PDF"] = Set.new %w(PDF_activate_item PDF_activate_item PDF_add_annotation PDF_add_bookmark PDF_add_launchlink PDF_add_locallink PDF_add_nameddest PDF_add_note PDF_add_outline PDF_add_pdflink PDF_add_table_cell PDF_add_textflow PDF_add_thumbnail PDF_add_weblink PDF_arc PDF_arcn PDF_attach_file PDF_begin_document PDF_begin_font PDF_begin_glyph PDF_begin_item PDF_begin_layer PDF_begin_page_ext PDF_begin_page PDF_begin_pattern PDF_begin_template_ext PDF_begin_template PDF_circle PDF_clip PDF_close_image PDF_close_pdi_page PDF_close_pdi PDF_close PDF_closepath_fill_stroke PDF_closepath_stroke PDF_closepath PDF_concat PDF_continue_text PDF_create_3dview PDF_create_action PDF_create_annotation PDF_create_bookmark PDF_create_field PDF_create_fieldgroup PDF_create_gstate PDF_create_pvf PDF_create_textflow PDF_curveto PDF_define_layer PDF_delete_pvf PDF_delete_table PDF_delete_textflow PDF_delete PDF_encoding_set_char PDF_end_document PDF_end_font PDF_end_glyph PDF_end_item PDF_end_layer PDF_end_page_ext PDF_end_page PDF_end_pattern PDF_end_template PDF_endpath PDF_fill_imageblock PDF_fill_pdfblock PDF_fill_stroke PDF_fill_textblock PDF_fill PDF_findfont PDF_fit_image PDF_fit_pdi_page PDF_fit_table PDF_fit_textflow PDF_fit_textline PDF_get_apiname PDF_get_buffer PDF_get_errmsg PDF_get_errnum PDF_get_font PDF_get_fontname PDF_get_fontsize PDF_get_image_height PDF_get_image_width PDF_get_majorversion PDF_get_minorversion PDF_get_parameter PDF_get_pdi_parameter PDF_get_pdi_value PDF_get_value PDF_info_font PDF_info_matchbox PDF_info_table PDF_info_textflow PDF_info_textline PDF_initgraphics PDF_lineto PDF_load_3ddata PDF_load_font PDF_load_iccprofile PDF_load_image PDF_makespotcolor PDF_moveto PDF_new PDF_open_ccitt PDF_open_file PDF_open_gif PDF_open_image_file PDF_open_image PDF_open_jpeg PDF_open_memory_image PDF_open_pdi_document PDF_open_pdi_page PDF_open_pdi PDF_open_tiff PDF_pcos_get_number PDF_pcos_get_stream PDF_pcos_get_string PDF_place_image PDF_place_pdi_page PDF_process_pdi PDF_rect PDF_restore PDF_resume_page PDF_rotate PDF_save PDF_scale PDF_set_border_color PDF_set_border_dash PDF_set_border_style PDF_set_char_spacing PDF_set_duration PDF_set_gstate PDF_set_horiz_scaling PDF_set_info_author PDF_set_info_creator PDF_set_info_keywords PDF_set_info_subject PDF_set_info_title PDF_set_info PDF_set_layer_dependency PDF_set_leading PDF_set_parameter PDF_set_text_matrix PDF_set_text_pos PDF_set_text_rendering PDF_set_text_rise PDF_set_value PDF_set_word_spacing PDF_setcolor PDF_setdash PDF_setdashpattern PDF_setflat PDF_setfont PDF_setgray_fill PDF_setgray_stroke PDF_setgray PDF_setlinecap PDF_setlinejoin PDF_setlinewidth PDF_setmatrix PDF_setmiterlimit PDF_setpolydash PDF_setrgbcolor_fill PDF_setrgbcolor_stroke PDF_setrgbcolor PDF_shading_pattern PDF_shading PDF_shfill PDF_show_boxed PDF_show_xy PDF_show PDF_skew PDF_stringwidth PDF_stroke PDF_suspend_page PDF_translate PDF_utf16_to_utf8 PDF_utf32_to_utf16 PDF_utf8_to_utf16 PDF_activate_item)
          b["PostgreSQL"] = Set.new %w(pg_affected_rows pg_affected_rows pg_cancel_query pg_client_encoding pg_close pg_connect pg_connection_busy pg_connection_reset pg_connection_status pg_convert pg_copy_from pg_copy_to pg_dbname pg_delete pg_end_copy pg_escape_bytea pg_escape_identifier pg_escape_literal pg_escape_string pg_execute pg_fetch_all_columns pg_fetch_all pg_fetch_array pg_fetch_assoc pg_fetch_object pg_fetch_result pg_fetch_row pg_field_is_null pg_field_name pg_field_num pg_field_prtlen pg_field_size pg_field_table pg_field_type_oid pg_field_type pg_free_result pg_get_notify pg_get_pid pg_get_result pg_host pg_insert pg_last_error pg_last_notice pg_last_oid pg_lo_close pg_lo_create pg_lo_export pg_lo_import pg_lo_open pg_lo_read_all pg_lo_read pg_lo_seek pg_lo_tell pg_lo_unlink pg_lo_write pg_meta_data pg_num_fields pg_num_rows pg_options pg_parameter_status pg_pconnect pg_ping pg_port pg_prepare pg_put_line pg_query_params pg_query pg_result_error_field pg_result_error pg_result_seek pg_result_status pg_select pg_send_execute pg_send_prepare pg_send_query_params pg_send_query pg_set_client_encoding pg_set_error_verbosity pg_trace pg_transaction_status pg_tty pg_unescape_bytea pg_untrace pg_update pg_version pg_affected_rows)
          b["POSIX"] = Set.new %w(posix_access posix_access posix_ctermid posix_errno posix_get_last_error posix_getcwd posix_getegid posix_geteuid posix_getgid posix_getgrgid posix_getgrnam posix_getgroups posix_getlogin posix_getpgid posix_getpgrp posix_getpid posix_getppid posix_getpwnam posix_getpwuid posix_getrlimit posix_getsid posix_getuid posix_initgroups posix_isatty posix_kill posix_mkfifo posix_mknod posix_setegid posix_seteuid posix_setgid posix_setpgid posix_setsid posix_setuid posix_strerror posix_times posix_ttyname posix_uname posix_access)
          b["Printer"] = Set.new %w(printer_abort printer_abort printer_close printer_create_brush printer_create_dc printer_create_font printer_create_pen printer_delete_brush printer_delete_dc printer_delete_font printer_delete_pen printer_draw_bmp printer_draw_chord printer_draw_elipse printer_draw_line printer_draw_pie printer_draw_rectangle printer_draw_roundrect printer_draw_text printer_end_doc printer_end_page printer_get_option printer_list printer_logical_fontheight printer_open printer_select_brush printer_select_font printer_select_pen printer_set_option printer_start_doc printer_start_page printer_write printer_abort)
          b["Proctitle"] = Set.new %w(setproctitle setproctitle setthreadtitle setproctitle)
          b["PS"] = Set.new %w(ps_add_bookmark ps_add_bookmark ps_add_launchlink ps_add_locallink ps_add_note ps_add_pdflink ps_add_weblink ps_arc ps_arcn ps_begin_page ps_begin_pattern ps_begin_template ps_circle ps_clip ps_close_image ps_close ps_closepath_stroke ps_closepath ps_continue_text ps_curveto ps_delete ps_end_page ps_end_pattern ps_end_template ps_fill_stroke ps_fill ps_findfont ps_get_buffer ps_get_parameter ps_get_value ps_hyphenate ps_include_file ps_lineto ps_makespotcolor ps_moveto ps_new ps_open_file ps_open_image_file ps_open_image ps_open_memory_image ps_place_image ps_rect ps_restore ps_rotate ps_save ps_scale ps_set_border_color ps_set_border_dash ps_set_border_style ps_set_info ps_set_parameter ps_set_text_pos ps_set_value ps_setcolor ps_setdash ps_setflat ps_setfont ps_setgray ps_setlinecap ps_setlinejoin ps_setlinewidth ps_setmiterlimit ps_setoverprintmode ps_setpolydash ps_shading_pattern ps_shading ps_shfill ps_show_boxed ps_show_xy2 ps_show_xy ps_show2 ps_show ps_string_geometry ps_stringwidth ps_stroke ps_symbol_name ps_symbol_width ps_symbol ps_translate ps_add_bookmark)
          b["Pspell"] = Set.new %w(pspell_add_to_personal pspell_add_to_personal pspell_add_to_session pspell_check pspell_clear_session pspell_config_create pspell_config_data_dir pspell_config_dict_dir pspell_config_ignore pspell_config_mode pspell_config_personal pspell_config_repl pspell_config_runtogether pspell_config_save_repl pspell_new_config pspell_new_personal pspell_new pspell_save_wordlist pspell_store_replacement pspell_suggest pspell_add_to_personal)
          b["qtdom"] = Set.new %w(qdom_error qdom_error qdom_tree qdom_error)
          b["Radius"] = Set.new %w(radius_acct_open radius_acct_open radius_add_server radius_auth_open radius_close radius_config radius_create_request radius_cvt_addr radius_cvt_int radius_cvt_string radius_demangle_mppe_key radius_demangle radius_get_attr radius_get_vendor_attr radius_put_addr radius_put_attr radius_put_int radius_put_string radius_put_vendor_addr radius_put_vendor_attr radius_put_vendor_int radius_put_vendor_string radius_request_authenticator radius_send_request radius_server_secret radius_strerror radius_acct_open)
          b["Rar"] = Set.new %w(rar_wrapper_cache_stats rar_wrapper_cache_stats rar_wrapper_cache_stats)
          b["Readline"] = Set.new %w(readline_add_history readline_add_history readline_callback_handler_install readline_callback_handler_remove readline_callback_read_char readline_clear_history readline_completion_function readline_info readline_list_history readline_on_new_line readline_read_history readline_redisplay readline_write_history readline readline_add_history)
          b["Recode"] = Set.new %w(recode_file recode_file recode_string recode recode_file)
          b["POSIX Regex"] = Set.new %w(ereg_replace ereg_replace ereg eregi_replace eregi split spliti sql_regcase ereg_replace)
          b["RPM Reader"] = Set.new %w(rpm_close rpm_close rpm_get_tag rpm_is_valid rpm_open rpm_version rpm_close)
          b["RRD"] = Set.new %w(rrd_create rrd_create rrd_error rrd_fetch rrd_first rrd_graph rrd_info rrd_last rrd_lastupdate rrd_restore rrd_tune rrd_update rrd_version rrd_xport rrd_create)
          b["runkit"] = Set.new %w(runkit_class_adopt runkit_class_emancipate runkit_constant_add runkit_constant_redefine runkit_constant_remove runkit_function_add runkit_function_copy runkit_function_redefine runkit_function_remove runkit_function_rename runkit_import runkit_lint_file runkit_lint runkit_method_add runkit_method_copy runkit_method_redefine runkit_method_remove runkit_method_rename runkit_return_value_used runkit_sandbox_output_handler runkit_superglobals)
          b["SAM"] = Set.new %w()
          b["SCA"] = Set.new %w()
          b["SDO DAS XML"] = Set.new %w()
          b["SDO"] = Set.new %w()
          b["SDO-DAS-Relational"] = Set.new %w()
          b["Semaphore"] = Set.new %w(ftok ftok msg_get_queue msg_queue_exists msg_receive msg_remove_queue msg_send msg_set_queue msg_stat_queue sem_acquire sem_get sem_release sem_remove shm_attach shm_detach shm_get_var shm_has_var shm_put_var shm_remove_var shm_remove ftok)
          b["Session PgSQL"] = Set.new %w(session_pgsql_add_error session_pgsql_add_error session_pgsql_get_error session_pgsql_get_field session_pgsql_reset session_pgsql_set_field session_pgsql_status session_pgsql_add_error)
          b["Session"] = Set.new %w(session_cache_expire session_cache_expire session_cache_limiter session_commit session_decode session_destroy session_encode session_get_cookie_params session_id session_is_registered session_module_name session_name session_regenerate_id session_register_shutdown session_register session_save_path session_set_cookie_params session_set_save_handler session_start session_status session_unregister session_unset session_write_close session_cache_expire)
          b["Shared Memory"] = Set.new %w(shmop_close shmop_close shmop_delete shmop_open shmop_read shmop_size shmop_write shmop_close)
          b["SimpleXML"] = Set.new %w(simplexml_import_dom simplexml_import_dom simplexml_load_file simplexml_load_string simplexml_import_dom)
          b["SNMP"] = Set.new %w(snmp_get_quick_print snmp_get_quick_print snmp_get_valueretrieval snmp_read_mib snmp_set_enum_print snmp_set_oid_numeric_print snmp_set_oid_output_format snmp_set_quick_print snmp_set_valueretrieval snmp2_get snmp2_getnext snmp2_real_walk snmp2_set snmp2_walk snmp3_get snmp3_getnext snmp3_real_walk snmp3_set snmp3_walk snmpget snmpgetnext snmprealwalk snmpset snmpwalk snmpwalkoid snmp_get_quick_print)
          b["SOAP"] = Set.new %w(is_soap_fault is_soap_fault use_soap_error_handler is_soap_fault)
          b["Socket"] = Set.new %w(socket_accept socket_accept socket_bind socket_clear_error socket_close socket_connect socket_create_listen socket_create_pair socket_create socket_get_option socket_getpeername socket_getsockname socket_import_stream socket_last_error socket_listen socket_read socket_recv socket_recvfrom socket_select socket_send socket_sendto socket_set_block socket_set_nonblock socket_set_option socket_shutdown socket_strerror socket_write socket_accept)
          b["Solr"] = Set.new %w(solr_get_version solr_get_version solr_get_version)
          b["SPL"] = Set.new %w(class_implements class_implements class_parents class_uses iterator_apply iterator_count iterator_to_array spl_autoload_call spl_autoload_extensions spl_autoload_functions spl_autoload_register spl_autoload_unregister spl_autoload spl_classes spl_object_hash class_implements)
          b["SPPLUS"] = Set.new %w(calcul_hmac calcul_hmac calculhmac nthmac signeurlpaiement calcul_hmac)
          b["SQLite"] = Set.new %w(sqlite_array_query sqlite_array_query sqlite_busy_timeout sqlite_changes sqlite_close sqlite_column sqlite_create_aggregate sqlite_create_function sqlite_current sqlite_error_string sqlite_escape_string sqlite_exec sqlite_factory sqlite_fetch_all sqlite_fetch_array sqlite_fetch_column_types sqlite_fetch_object sqlite_fetch_single sqlite_fetch_string sqlite_field_name sqlite_has_more sqlite_has_prev sqlite_key sqlite_last_error sqlite_last_insert_rowid sqlite_libencoding sqlite_libversion sqlite_next sqlite_num_fields sqlite_num_rows sqlite_open sqlite_popen sqlite_prev sqlite_query sqlite_rewind sqlite_seek sqlite_single_query sqlite_udf_decode_binary sqlite_udf_encode_binary sqlite_unbuffered_query sqlite_valid sqlite_array_query)
          b["SQLSRV"] = Set.new %w(sqlsrv_begin_transaction sqlsrv_begin_transaction sqlsrv_cancel sqlsrv_client_info sqlsrv_close sqlsrv_commit sqlsrv_configure sqlsrv_connect sqlsrv_errors sqlsrv_execute sqlsrv_fetch_array sqlsrv_fetch_object sqlsrv_fetch sqlsrv_field_metadata sqlsrv_free_stmt sqlsrv_get_config sqlsrv_get_field sqlsrv_has_rows sqlsrv_next_result sqlsrv_num_fields sqlsrv_num_rows sqlsrv_prepare sqlsrv_query sqlsrv_rollback sqlsrv_rows_affected sqlsrv_send_stream_data sqlsrv_server_info sqlsrv_begin_transaction)
          b["ssdeep"] = Set.new %w(ssdeep_fuzzy_compare ssdeep_fuzzy_compare ssdeep_fuzzy_hash_filename ssdeep_fuzzy_hash ssdeep_fuzzy_compare)
          b["SSH2"] = Set.new %w(ssh2_auth_hostbased_file ssh2_auth_hostbased_file ssh2_auth_none ssh2_auth_password ssh2_auth_pubkey_file ssh2_connect ssh2_exec ssh2_fetch_stream ssh2_fingerprint ssh2_methods_negotiated ssh2_publickey_add ssh2_publickey_init ssh2_publickey_list ssh2_publickey_remove ssh2_scp_recv ssh2_scp_send ssh2_sftp_lstat ssh2_sftp_mkdir ssh2_sftp_readlink ssh2_sftp_realpath ssh2_sftp_rename ssh2_sftp_rmdir ssh2_sftp_stat ssh2_sftp_symlink ssh2_sftp_unlink ssh2_sftp ssh2_shell ssh2_tunnel ssh2_auth_hostbased_file)
          b["Statistic"] = Set.new %w(stats_absolute_deviation stats_absolute_deviation stats_cdf_beta stats_cdf_binomial stats_cdf_cauchy stats_cdf_chisquare stats_cdf_exponential stats_cdf_f stats_cdf_gamma stats_cdf_laplace stats_cdf_logistic stats_cdf_negative_binomial stats_cdf_noncentral_chisquare stats_cdf_noncentral_f stats_cdf_poisson stats_cdf_t stats_cdf_uniform stats_cdf_weibull stats_covariance stats_den_uniform stats_dens_beta stats_dens_cauchy stats_dens_chisquare stats_dens_exponential stats_dens_f stats_dens_gamma stats_dens_laplace stats_dens_logistic stats_dens_negative_binomial stats_dens_normal stats_dens_pmf_binomial stats_dens_pmf_hypergeometric stats_dens_pmf_poisson stats_dens_t stats_dens_weibull stats_harmonic_mean stats_kurtosis stats_rand_gen_beta stats_rand_gen_chisquare stats_rand_gen_exponential stats_rand_gen_f stats_rand_gen_funiform stats_rand_gen_gamma stats_rand_gen_ibinomial_negative stats_rand_gen_ibinomial stats_rand_gen_int stats_rand_gen_ipoisson stats_rand_gen_iuniform stats_rand_gen_noncenral_chisquare stats_rand_gen_noncentral_f stats_rand_gen_noncentral_t stats_rand_gen_normal stats_rand_gen_t stats_rand_get_seeds stats_rand_phrase_to_seeds stats_rand_ranf stats_rand_setall stats_skew stats_standard_deviation stats_stat_binomial_coef stats_stat_correlation stats_stat_gennch stats_stat_independent_t stats_stat_innerproduct stats_stat_noncentral_t stats_stat_paired_t stats_stat_percentile stats_stat_powersum stats_variance stats_absolute_deviation)
          b["Stomp"] = Set.new %w(stomp_connect_error stomp_connect_error stomp_version stomp_connect_error)
          b["Stream"] = Set.new %w(set_socket_blocking set_socket_blocking stream_bucket_append stream_bucket_make_writeable stream_bucket_new stream_bucket_prepend stream_context_create stream_context_get_default stream_context_get_options stream_context_get_params stream_context_set_default stream_context_set_option stream_context_set_params stream_copy_to_stream stream_encoding stream_filter_append stream_filter_prepend stream_filter_register stream_filter_remove stream_get_contents stream_get_filters stream_get_line stream_get_meta_data stream_get_transports stream_get_wrappers stream_is_local stream_notification_callback stream_register_wrapper stream_resolve_include_path stream_select stream_set_blocking stream_set_chunk_size stream_set_read_buffer stream_set_timeout stream_set_write_buffer stream_socket_accept stream_socket_client stream_socket_enable_crypto stream_socket_get_name stream_socket_pair stream_socket_recvfrom stream_socket_sendto stream_socket_server stream_socket_shutdown stream_supports_lock stream_wrapper_register stream_wrapper_restore stream_wrapper_unregister set_socket_blocking)
          b["String"] = Set.new %w(addcslashes addcslashes addslashes bin2hex chop chr chunk_split convert_cyr_string convert_uudecode convert_uuencode count_chars crc32 crypt echo explode fprintf get_html_translation_table hebrev hebrevc hex2bin html_entity_decode htmlentities htmlspecialchars_decode htmlspecialchars implode join lcfirst levenshtein localeconv ltrim md5_file md5 metaphone money_format nl_langinfo nl2br number_format ord parse_str print printf quoted_printable_decode quoted_printable_encode quotemeta rtrim setlocale sha1_file sha1 similar_text soundex sprintf sscanf str_getcsv str_ireplace str_pad str_repeat str_replace str_rot13 str_shuffle str_split str_word_count strcasecmp strchr strcmp strcoll strcspn strip_tags stripcslashes stripos stripslashes stristr strlen strnatcasecmp strnatcmp strncasecmp strncmp strpbrk strpos strrchr strrev strripos strrpos strspn strstr strtok strtolower strtoupper strtr substr_compare substr_count substr_replace substr trim ucfirst ucwords vfprintf vprintf vsprintf wordwrap addcslashes)
          b["SVN"] = Set.new %w(svn_add svn_add svn_auth_get_parameter svn_auth_set_parameter svn_blame svn_cat svn_checkout svn_cleanup svn_client_version svn_commit svn_delete svn_diff svn_export svn_fs_abort_txn svn_fs_apply_text svn_fs_begin_txn2 svn_fs_change_node_prop svn_fs_check_path svn_fs_contents_changed svn_fs_copy svn_fs_delete svn_fs_dir_entries svn_fs_file_contents svn_fs_file_length svn_fs_is_dir svn_fs_is_file svn_fs_make_dir svn_fs_make_file svn_fs_node_created_rev svn_fs_node_prop svn_fs_props_changed svn_fs_revision_prop svn_fs_revision_root svn_fs_txn_root svn_fs_youngest_rev svn_import svn_log svn_ls svn_mkdir svn_repos_create svn_repos_fs_begin_txn_for_commit svn_repos_fs_commit_txn svn_repos_fs svn_repos_hotcopy svn_repos_open svn_repos_recover svn_revert svn_status svn_update svn_add)
          b["SWF"] = Set.new %w(swf_actiongeturl swf_actiongeturl swf_actiongotoframe swf_actiongotolabel swf_actionnextframe swf_actionplay swf_actionprevframe swf_actionsettarget swf_actionstop swf_actiontogglequality swf_actionwaitforframe swf_addbuttonrecord swf_addcolor swf_closefile swf_definebitmap swf_definefont swf_defineline swf_definepoly swf_definerect swf_definetext swf_endbutton swf_enddoaction swf_endshape swf_endsymbol swf_fontsize swf_fontslant swf_fonttracking swf_getbitmapinfo swf_getfontinfo swf_getframe swf_labelframe swf_lookat swf_modifyobject swf_mulcolor swf_nextid swf_oncondition swf_openfile swf_ortho2 swf_ortho swf_perspective swf_placeobject swf_polarview swf_popmatrix swf_posround swf_pushmatrix swf_removeobject swf_rotate swf_scale swf_setfont swf_setframe swf_shapearc swf_shapecurveto3 swf_shapecurveto swf_shapefillbitmapclip swf_shapefillbitmaptile swf_shapefilloff swf_shapefillsolid swf_shapelinesolid swf_shapelineto swf_shapemoveto swf_showframe swf_startbutton swf_startdoaction swf_startshape swf_startsymbol swf_textwidth swf_translate swf_viewport swf_actiongeturl)
          b["Swish"] = Set.new %w()
          b["Sybase"] = Set.new %w(sybase_affected_rows sybase_affected_rows sybase_close sybase_connect sybase_data_seek sybase_deadlock_retry_count sybase_fetch_array sybase_fetch_assoc sybase_fetch_field sybase_fetch_object sybase_fetch_row sybase_field_seek sybase_free_result sybase_get_last_message sybase_min_client_severity sybase_min_error_severity sybase_min_message_severity sybase_min_server_severity sybase_num_fields sybase_num_rows sybase_pconnect sybase_query sybase_result sybase_select_db sybase_set_message_handler sybase_unbuffered_query sybase_affected_rows)
          b["Taint"] = Set.new %w(is_tainted is_tainted taint untaint is_tainted)
          b["TCP"] = Set.new %w(tcpwrap_check tcpwrap_check tcpwrap_check)
          b["Tidy"] = Set.new %w(ob_tidyhandler ob_tidyhandler tidy_access_count tidy_config_count tidy_error_count tidy_get_output tidy_load_config tidy_reset_config tidy_save_config tidy_set_encoding tidy_setopt tidy_warning_count ob_tidyhandler)
          b["Tokenizer"] = Set.new %w(token_get_all token_get_all token_name token_get_all)
          b["Trader"] = Set.new %w(trader_acos trader_acos trader_ad trader_add trader_adosc trader_adx trader_adxr trader_apo trader_aroon trader_aroonosc trader_asin trader_atan trader_atr trader_avgprice trader_bbands trader_beta trader_bop trader_cci trader_cdl2crows trader_cdl3blackcrows trader_cdl3inside trader_cdl3linestrike trader_cdl3outside trader_cdl3starsinsouth trader_cdl3whitesoldiers trader_cdlabandonedbaby trader_cdladvanceblock trader_cdlbelthold trader_cdlbreakaway trader_cdlclosingmarubozu trader_cdlconcealbabyswall trader_cdlcounterattack trader_cdldarkcloudcover trader_cdldoji trader_cdldojistar trader_cdldragonflydoji trader_cdlengulfing trader_cdleveningdojistar trader_cdleveningstar trader_cdlgapsidesidewhite trader_cdlgravestonedoji trader_cdlhammer trader_cdlhangingman trader_cdlharami trader_cdlharamicross trader_cdlhighwave trader_cdlhikkake trader_cdlhikkakemod trader_cdlhomingpigeon trader_cdlidentical3crows trader_cdlinneck trader_cdlinvertedhammer trader_cdlkicking trader_cdlkickingbylength trader_cdlladderbottom trader_cdllongleggeddoji trader_cdllongline trader_cdlmarubozu trader_cdlmatchinglow trader_cdlmathold trader_cdlmorningdojistar trader_cdlmorningstar trader_cdlonneck trader_cdlpiercing trader_cdlrickshawman trader_cdlrisefall3methods trader_cdlseparatinglines trader_cdlshootingstar trader_cdlshortline trader_cdlspinningtop trader_cdlstalledpattern trader_cdlsticksandwich trader_cdltakuri trader_cdltasukigap trader_cdlthrusting trader_cdltristar trader_cdlunique3river trader_cdlupsidegap2crows trader_cdlxsidegap3methods trader_ceil trader_cmo trader_correl trader_cos trader_cosh trader_dema trader_div trader_dx trader_ema trader_errno trader_exp trader_floor trader_get_compat trader_get_unstable_period trader_ht_dcperiod trader_ht_dcphase trader_ht_phasor trader_ht_sine trader_ht_trendline trader_ht_trendmode trader_kama trader_linearreg_angle trader_linearreg_intercept trader_linearreg_slope trader_linearreg trader_ln trader_log10 trader_ma trader_macd trader_macdext trader_macdfix trader_mama trader_mavp trader_max trader_maxindex trader_medprice trader_mfi trader_midpoint trader_midprice trader_min trader_minindex trader_minmax trader_minmaxindex trader_minus_di trader_minus_dm trader_mom trader_mult trader_natr trader_obv trader_plus_di trader_plus_dm trader_ppo trader_roc trader_rocp trader_rocr100 trader_rocr trader_rsi trader_sar trader_sarext trader_set_compat trader_set_unstable_period trader_sin trader_sinh trader_sma trader_sqrt trader_stddev trader_stoch trader_stochf trader_stochrsi trader_sub trader_sum trader_t3 trader_tan trader_tanh trader_tema trader_trange trader_trima trader_trix trader_tsf trader_typprice trader_ultosc trader_var trader_wclprice trader_willr trader_wma trader_acos)
          b["ODBC"] = Set.new %w(odbc_autocommit odbc_autocommit odbc_binmode odbc_close_all odbc_close odbc_columnprivileges odbc_columns odbc_commit odbc_connect odbc_cursor odbc_data_source odbc_do odbc_error odbc_errormsg odbc_exec odbc_execute odbc_fetch_array odbc_fetch_into odbc_fetch_object odbc_fetch_row odbc_field_len odbc_field_name odbc_field_num odbc_field_precision odbc_field_scale odbc_field_type odbc_foreignkeys odbc_free_result odbc_gettypeinfo odbc_longreadlen odbc_next_result odbc_num_fields odbc_num_rows odbc_pconnect odbc_prepare odbc_primarykeys odbc_procedurecolumns odbc_procedures odbc_result_all odbc_result odbc_rollback odbc_setoption odbc_specialcolumns odbc_statistics odbc_tableprivileges odbc_tables odbc_autocommit)
          b["URL"] = Set.new %w(base64_decode base64_decode base64_encode get_headers get_meta_tags http_build_query parse_url rawurldecode rawurlencode urldecode urlencode base64_decode)
          b["Variable handling"] = Set.new %w(debug_zval_dump debug_zval_dump doubleval empty floatval get_defined_vars get_resource_type gettype import_request_variables intval is_array is_bool is_callable is_double is_float is_int is_integer is_long is_null is_numeric is_object is_real is_resource is_scalar is_string isset print_r serialize settype strval unserialize unset var_dump var_export debug_zval_dump)
          b["vpopmail"] = Set.new %w(vpopmail_add_alias_domain_ex vpopmail_add_alias_domain_ex vpopmail_add_alias_domain vpopmail_add_domain_ex vpopmail_add_domain vpopmail_add_user vpopmail_alias_add vpopmail_alias_del_domain vpopmail_alias_del vpopmail_alias_get_all vpopmail_alias_get vpopmail_auth_user vpopmail_del_domain_ex vpopmail_del_domain vpopmail_del_user vpopmail_error vpopmail_passwd vpopmail_set_user_quota vpopmail_add_alias_domain_ex)
          b["W32api"] = Set.new %w(w32api_deftype w32api_deftype w32api_init_dtype w32api_invoke_function w32api_register_function w32api_set_call_method w32api_deftype)
          b["WDDX"] = Set.new %w(wddx_add_vars wddx_add_vars wddx_deserialize wddx_packet_end wddx_packet_start wddx_serialize_value wddx_serialize_vars wddx_add_vars)
          b["win32ps"] = Set.new %w(win32_ps_list_procs win32_ps_list_procs win32_ps_stat_mem win32_ps_stat_proc win32_ps_list_procs)
          b["win32service"] = Set.new %w(win32_continue_service win32_continue_service win32_create_service win32_delete_service win32_get_last_control_message win32_pause_service win32_query_service_status win32_set_service_status win32_start_service_ctrl_dispatcher win32_start_service win32_stop_service win32_continue_service)
          b["WinCache"] = Set.new %w(wincache_fcache_fileinfo wincache_fcache_fileinfo wincache_fcache_meminfo wincache_lock wincache_ocache_fileinfo wincache_ocache_meminfo wincache_refresh_if_changed wincache_rplist_fileinfo wincache_rplist_meminfo wincache_scache_info wincache_scache_meminfo wincache_ucache_add wincache_ucache_cas wincache_ucache_clear wincache_ucache_dec wincache_ucache_delete wincache_ucache_exists wincache_ucache_get wincache_ucache_inc wincache_ucache_info wincache_ucache_meminfo wincache_ucache_set wincache_unlock wincache_fcache_fileinfo)
          b["xattr"] = Set.new %w(xattr_get xattr_get xattr_list xattr_remove xattr_set xattr_supported xattr_get)
          b["xdiff"] = Set.new %w(xdiff_file_bdiff_size xdiff_file_bdiff_size xdiff_file_bdiff xdiff_file_bpatch xdiff_file_diff_binary xdiff_file_diff xdiff_file_merge3 xdiff_file_patch_binary xdiff_file_patch xdiff_file_rabdiff xdiff_string_bdiff_size xdiff_string_bdiff xdiff_string_bpatch xdiff_string_diff_binary xdiff_string_diff xdiff_string_merge3 xdiff_string_patch_binary xdiff_string_patch xdiff_string_rabdiff xdiff_file_bdiff_size)
          b["Xhprof"] = Set.new %w(xhprof_disable xhprof_disable xhprof_enable xhprof_sample_disable xhprof_sample_enable xhprof_disable)
          b["XML Parser"] = Set.new %w(utf8_decode utf8_decode utf8_encode xml_error_string xml_get_current_byte_index xml_get_current_column_number xml_get_current_line_number xml_get_error_code xml_parse_into_struct xml_parse xml_parser_create_ns xml_parser_create xml_parser_free xml_parser_get_option xml_parser_set_option xml_set_character_data_handler xml_set_default_handler xml_set_element_handler xml_set_end_namespace_decl_handler xml_set_external_entity_ref_handler xml_set_notation_decl_handler xml_set_object xml_set_processing_instruction_handler xml_set_start_namespace_decl_handler xml_set_unparsed_entity_decl_handler utf8_decode)
          b["XML-RPC"] = Set.new %w(xmlrpc_decode_request xmlrpc_decode_request xmlrpc_decode xmlrpc_encode_request xmlrpc_encode xmlrpc_get_type xmlrpc_is_fault xmlrpc_parse_method_descriptions xmlrpc_server_add_introspection_data xmlrpc_server_call_method xmlrpc_server_create xmlrpc_server_destroy xmlrpc_server_register_introspection_callback xmlrpc_server_register_method xmlrpc_set_type xmlrpc_decode_request)
          b["XMLWriter"] = Set.new %w(XMLWriter::endAttribute XMLWriter::endAttribute XMLWriter::endCData XMLWriter::endComment XMLWriter::endDocument XMLWriter::endDTDAttlist XMLWriter::endDTDElement XMLWriter::endDTDEntity XMLWriter::endDTD XMLWriter::endElement XMLWriter::endPI XMLWriter::flush XMLWriter::fullEndElement XMLWriter::openMemory XMLWriter::openURI XMLWriter::outputMemory XMLWriter::setIndentString XMLWriter::setIndent XMLWriter::startAttributeNS XMLWriter::startAttribute XMLWriter::startCData XMLWriter::startComment XMLWriter::startDocument XMLWriter::startDTDAttlist XMLWriter::startDTDElement XMLWriter::startDTDEntity XMLWriter::startDTD XMLWriter::startElementNS XMLWriter::startElement XMLWriter::startPI XMLWriter::text XMLWriter::writeAttributeNS XMLWriter::writeAttribute XMLWriter::writeCData XMLWriter::writeComment XMLWriter::writeDTDAttlist XMLWriter::writeDTDElement XMLWriter::writeDTDEntity XMLWriter::writeDTD XMLWriter::writeElementNS XMLWriter::writeElement XMLWriter::writePI XMLWriter::writeRaw XMLWriter::endAttribute)
          b["XSLT (PHP 4)"] = Set.new %w(xslt_backend_info xslt_backend_info xslt_backend_name xslt_backend_version xslt_create xslt_errno xslt_error xslt_free xslt_getopt xslt_process xslt_set_base xslt_set_encoding xslt_set_error_handler xslt_set_log xslt_set_object xslt_set_sax_handler xslt_set_sax_handlers xslt_set_scheme_handler xslt_set_scheme_handlers xslt_setopt xslt_backend_info)
          b["Yaml"] = Set.new %w(yaml_emit_file yaml_emit_file yaml_emit yaml_parse_file yaml_parse_url yaml_parse yaml_emit_file)
          b["YAZ"] = Set.new %w(yaz_addinfo yaz_addinfo yaz_ccl_conf yaz_ccl_parse yaz_close yaz_connect yaz_database yaz_element yaz_errno yaz_error yaz_es_result yaz_es yaz_get_option yaz_hits yaz_itemorder yaz_present yaz_range yaz_record yaz_scan_result yaz_scan yaz_schema yaz_search yaz_set_option yaz_sort yaz_syntax yaz_wait yaz_addinfo)
          b["Zip"] = Set.new %w(zip_close zip_close zip_entry_close zip_entry_compressedsize zip_entry_compressionmethod zip_entry_filesize zip_entry_name zip_entry_open zip_entry_read zip_open zip_read zip_close)
          b["Zlib"] = Set.new %w(gzclose gzclose gzcompress gzdecode gzdeflate gzencode gzeof gzfile gzgetc gzgets gzgetss gzinflate gzopen gzpassthru gzputs gzread gzrewind gzseek gztell gzuncompress gzwrite readgzfile zlib_decode zlib_encode zlib_get_coding_type gzclose)
        end
      end
    end
  end
end
module Rouge
  module Lexers
    class PHP < TemplateLexer
      desc "The PHP scripting language (php.net)"
      tag 'php'
      aliases 'php', 'php3', 'php4', 'php5'
      filenames '*.php', '*.php[345]'
      mimetypes 'text/x-php'

      default_options :parent => 'html'

      def initialize(opts={})
        # if truthy, the lexer starts highlighting with php code
        # (no <?php required)
        @start_inline = opts.delete(:start_inline)
        @funcnamehighlighting = opts.delete(:funcnamehighlighting) { true }
        @disabledmodules = opts.delete(:disabledmodules) { [] }

        super(opts)
      end

      def self.builtins
        load Pathname.new(__FILE__).dirname.join('php/builtins.rb')
        self.builtins
      end

      def builtins
        return [] unless @funcnamehighlighting

        @builtins ||= Set.new.tap do |builtins|
          self.class.builtins.each do |mod, fns|
            next if @disabledmodules.include? mod
            builtins.merge(fns)
          end
        end
      end

      def start_inline?
        !!@start_inline
      end

      start do
        push :php if start_inline?
      end

      keywords = %w(
        and E_PARSE old_function E_ERROR or as E_WARNING parent eval
        PHP_OS break exit case extends PHP_VERSION cfunction FALSE
        print for require continue foreach require_once declare return
        default static do switch die stdClass echo else TRUE elseif
        var empty if xor enddeclare include virtual endfor include_once
        while endforeach global __FILE__ endif list __LINE__ endswitch
        new __sleep endwhile not array __wakeup E_ALL NULL final
        php_user_filter interface implements public private protected
        abstract clone try catch throw this use namespace
      )

      state :root do
        rule /<\?(php|=)?/, 'Comment.Preproc', :php
        rule(/.*?(?=<\?)|.*/m) { delegate parent }
      end

      state :php do
        rule /\?>/, 'Comment.Preproc', :pop!
        # heredocs
        rule /<<<('?)([a-z_]\w*)\1\n.*?\n\2;?\n/im, 'String'
        rule /\s+/, 'Text'
        rule /#.*?\n/, 'Comment.Single'
        rule %r(//.*?\n), 'Comment.Single'
        # empty comment, otherwise seen as the start of a docstring
        rule %r(/\*\*/)
        rule %r(/\*\*.*?\*/)m, 'Literal.String.Doc'
        rule %r(/\*.*?\*/)m, 'Comment.Multiline'
        rule /(->|::)(\s*)([a-zA-Z_][a-zA-Z0-9_]*)/ do
          group 'Operator'; group 'Text'; group 'Name.Attribute'
        end

        rule /[~!%^&*+=\|:.<>\/?@-]+/, 'Operator'
        rule /[\[\]{}();,]+/, 'Punctuation'
        rule /class\b/, 'Keyword', :classname
        # anonymous functions
        rule /(function)(\s*)(?=\()/ do
          group 'Keyword'; group 'Text'
        end

        # named functions
        rule /(function)(\s+)(&?)(\s*)/ do
          group 'Keyword'; group 'Text'; group 'Operator'; group 'Text'
          push :funcname
        end

        rule /(const)(\s+)([a-zA-Z_]\w*)/i do
          group 'Keyword'; group 'Text'; group 'Name.Constant'
        end

        rule /(?:#{keywords.join('|')})\b/, 'Keyword'
        rule /(true|false|null)\b/, 'Keyword.Constant'
        rule /\$\{\$+[a-z_]\w*\}/i, 'Name.Variable'
        rule /\$+[a-z_]\w*/i, 'Name.Variable'

        # may be intercepted for builtin highlighting
        rule /[\\a-z_][\\\w]*/i, 'Name.Other'

        rule /(\d+\.\d*|\d*\.\d+)(e[+-]?\d+)?/i, 'Literal.Number.Float'
        rule /\d+e[+-]?\d+/i, 'Literal.Number.Float'
        rule /0[0-7]+/, 'Literal.Number.Oct'
        rule /0x[a-f0-9]+/i, 'Literal.Number.Hex'
        rule /\d+/, 'Literal.Number.Integer'
        rule /'([^'\\]*(?:\\.[^'\\]*)*)'/, 'Literal.String.Single'
        rule /`([^`\\]*(?:\\.[^`\\]*)*)`/, 'Literal.String.Backtick'
        rule /"/, 'Literal.String.Double', :string
      end

      state :classname do
        rule /\s+/, 'Text'
        rule /[a-z_][\\\w]*/i, 'Name.Class', :pop!
      end

      state :funcname do
        rule /[a-z_]\w*/i, 'Name.Function', :pop!
      end

      state :string do
        rule /"/, 'Literal.String.Double', :pop!
        rule /[^\\{$"]+/, 'Literal.String.Double'
        rule /\\([nrt\"$\\]|[0-7]{1,3}|x[0-9A-Fa-f]{1,2})/,
          'Literal.String.Escape'
        rule /\$[a-zA-Z_][a-zA-Z0-9_]*(\[\S+\]|->[a-zA-Z_][a-zA-Z0-9_]*)?/

        lsi = 'Literal.String.Interpol'
        rule /\{\$\{/, lsi, :interp_double
        rule /\{(?=\$)/, lsi, :interp_single
        rule /(\{)(\S+)(\})/ do
          group lsi; group 'Name.Variable'; group lsi
        end

        rule /[${\\]+/, 'Literal.String.Double'
      end

      state :interp_double do
        rule /\}\}/, 'Literal.String.Interpol', :pop!
        mixin :php
      end

      state :interp_single do
        rule /\}/, 'Literal.String.Interpol', :pop!
        mixin :php
      end

      postprocess 'Name.Other' do |tok, val|
        tok = 'Name.Builtin' if builtins.include? val

        token tok, val
      end
    end
  end
end
module Rouge
  module Lexers
    class Python < RegexLexer
      desc "The Python programming language (python.org)"
      tag 'python'
      aliases 'py'
      filenames '*.py', '*.pyw', '*.sc', 'SConstruct', 'SConscript', '*.tac'
      mimetypes 'text/x-python', 'application/x-python'

      def self.analyze_text(text)
        return 1 if text.shebang?(/pythonw?(3|2(\.\d)?)?/)
      end

      keywords = %w(
        assert break continue del elif else except exec
        finally for global if lambda pass print raise
        return try while yield as with
      )

      builtins = %w(
        __import__ abs all any apply basestring bin bool buffer
        bytearray bytes callable chr classmethod cmp coerce compile
        complex delattr dict dir divmod enumerate eval execfile exit
        file filter float frozenset getattr globals hasattr hash hex id
        input int intern isinstance issubclass iter len list locals
        long map max min next object oct open ord pow property range
        raw_input reduce reload repr reversed round set setattr slice
        sorted staticmethod str sum super tuple type unichr unicode
        vars xrange zip
      )

      builtins_pseudo = %w(self None Ellipsis NotImplemented False True)

      exceptions = %w(
        ArithmeticError AssertionError AttributeError
        BaseException DeprecationWarning EOFError EnvironmentError
        Exception FloatingPointError FutureWarning GeneratorExit IOError
        ImportError ImportWarning IndentationError IndexError KeyError
        KeyboardInterrupt LookupError MemoryError NameError
        NotImplemented NotImplementedError OSError OverflowError
        OverflowWarning PendingDeprecationWarning ReferenceError
        RuntimeError RuntimeWarning StandardError StopIteration
        SyntaxError SyntaxWarning SystemError SystemExit TabError
        TypeError UnboundLocalError UnicodeDecodeError
        UnicodeEncodeError UnicodeError UnicodeTranslateError
        UnicodeWarning UserWarning ValueError VMSError Warning
        WindowsError ZeroDivisionError
      )

      identifier =        /[a-z_][a-z0-9_]*/i
      dotted_identifier = /[a-z_.][a-z0-9_.]*/i
      state :root do
        rule /\n+/m, 'Text'
        rule /^(:)(\s*)([ru]{,2}""".*?""")/mi do
          group 'Punctuation'
          group 'Text'
          group 'Literal.String.Doc'
        end

        rule /[^\S\n]+/, 'Text'
        rule /#.*$/, 'Comment'
        rule /[\[\]{}:(),;]/, 'Punctuation'
        rule /\\\n/, 'Text'
        rule /\\/, 'Text'

        rule /(in|is|and|or|not)\b/, 'Operator.Word'
        rule /!=|==|<<|>>|[-~+\/*%=<>&^|.]/, 'Operator'

        rule /(?:#{keywords.join('|')})\b/, 'Keyword'

        rule /(def)((?:\s|\\\s)+)/ do
          group 'Keyword' # def
          group 'Text' # whitespae
          push :funcname
        end

        rule /(class)((?:\s|\\\s)+)/ do
          group 'Keyword'
          group 'Text'
          push :classname
        end

        rule /(from)((?:\s|\\\s)+)/ do
          group 'Keyword.Namespace'
          group 'Text'
          push :fromimport
        end

        rule /(import)((?:\s|\\\s)+)/ do
          group 'Keyword.Namespace'
          group 'Text'
          push :import
        end

        # using negative lookbehind so we don't match property names
        rule /(?<!\.)(?:#{builtins.join('|')})/, 'Name.Builtin'
        rule /(?<!\.)(?:#{builtins_pseudo.join('|')})/, 'Name.Builtin.Pseudo'

        # TODO: not in python 3
        rule /`.*?`/, 'Literal.String.Backtick'
        rule /(?:r|ur|ru)"""/i, 'Literal.String', :tdqs
        rule /(?:r|ur|ru)'''/i, 'Literal.String', :tsqs
        rule /(?:r|ur|ru)"/i,   'Literal.String', :dqs
        rule /(?:r|ur|ru)'/i,   'Literal.String', :sqs
        rule /u?"""/i,          'Literal.String', :escape_tdqs
        rule /u?'''/i,          'Literal.String', :escape_tsqs
        rule /u?"/i,            'Literal.String', :escape_dqs
        rule /u?'/i,            'Literal.String', :escape_sqs

        rule /@#{dotted_identifier}/i, 'Name.Decorator'
        rule identifier, 'Name'

        rule /(\d+\.\d*|\d*\.\d+)(e[+-]?[0-9]+)?/i, 'Literal.Number.Float'
        rule /\d+e[+-]?[0-9]+/i, 'Literal.Number.Float'
        rule /0[0-7]+/, 'Literal.Number.Oct'
        rule /0x[a-f0-9]+/i, 'Literal.Number.Hex'
        rule /\d+L/, 'Literal.Number.Integer.Long'
        rule /\d+/, 'Literal.Number.Integer'
      end

      state :funcname do
        rule identifier, 'Name.Function', :pop!
      end

      state :classname do
        rule identifier, 'Name.Class', :pop!
      end

      state :import do
        # non-line-terminating whitespace
        rule /(?:[ \t]|\\\n)+/, 'Text'

        rule /as\b/, 'Keyword.Namespace'
        rule /,/, 'Operator'
        rule dotted_identifier, 'Name.Namespace'
        rule(//) { pop! } # anything else -> go back
      end

      state :fromimport do
        # non-line-terminating whitespace
        rule /(?:[ \t]|\\\n)+/, 'Text'

        rule /import\b/, 'Keyword.Namespace', :pop!
        rule dotted_identifier, 'Name.Namespace'
      end

      state :strings do
        rule /%(\([a-z0-9_]+\))?[-#0 +]*([0-9]+|[*])?(\.([0-9]+|[*]))?/i, 'Literal.String.Interpol'
        rule /[^\\'"%\n]+/, 'Literal.String'
      end

      state :nl do
        rule /\n/, 'Literal.String'
      end

      state :escape do
        rule %r(\\
          ( [\\abfnrtv"']
          | \n
          | N{.*?}
          | u[a-fA-F0-9]{4}
          | U[a-fA-F0-9]{8}
          | x[a-fA-F0-9]{2}
          | [0-7]{1,3}
          )
        )x, 'Literal.String.Escape'
      end

      state :dqs do
        rule /"/, 'Literal.String', :pop!
        rule /\\\\|\\"|\\\n/, 'Literal.String.Escape'
        mixin :strings
      end

      state :sqs do
        rule /'/, 'Literal.String', :pop!
        rule /\\\\|\\'|\\\n/, 'Literal.String.Escape'
        mixin :strings
      end

      state :tdqs do
        rule /"""/, 'Literal.String', :pop!
        mixin :strings
        mixin :nl
      end

      state :tsqs do
        rule /'''/, 'Literal.String', :pop!
        mixin :strings
        mixin :nl
      end

      %w(tdqs tsqs dqs sqs).each do |qtype|
        state :"escape_#{qtype}" do
          mixin :escape
          mixin :"#{qtype}"
        end
      end

    end
  end
end
