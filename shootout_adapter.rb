class ShootoutAdapter
  def self.load libraries
    libraries.map do |library_and_subversion|
      library, subversion = library_and_subversion.split(':', 2)
      library = library.gsub(/\W/, '')
      require_relative "adapters/#{library.downcase}"
      Adapters.const_get(library).new(subversion)
    end
  end

  attr :subversion

  def initialize subversion = nil
    @subversion = subversion
  end

  def library
    self.class::LIBRARY
  end

  def version
    library::VERSION
  end

  def name
    "#{library.name}#{" (#{subversion})" if subversion}".strip
  end

  def benchmark file, source, language, format, repeats, disable_gc
    language += subversion if subversion

    # warmup and check
    unless highlight file, "test\n<42>", language, format
      return
    end

    GC.disable if disable_gc
    require 'profile' if ENV['PROFILE']

    # benchmark
    time = Benchmark.realtime do
      repeats.times do
        @result = highlight file, source, language, format
      end
    end

    time / repeats
  ensure
    GC.enable && GC.start if disable_gc
  end

  def highlight file, source, language, format
  end

  def fast_ruby
    # loading bundler results in something like:
    #   RUBYOPT=-I~/.rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5/lib -rbundler/setup
    # which slows down ruby considerably. Use this one instead.
    'RUBYOPT= ruby'
  end
end
