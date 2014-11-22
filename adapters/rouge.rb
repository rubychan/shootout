module Adapters
  class Rouge < ShootoutAdapter
    LIBRARY = ::Rouge
    
    def version
      LIBRARY.version
    end
    
    def highlight file, source, language, format
      format = 'terminal256' if format == 'terminal'
      
      LIBRARY.highlight(source, language, format)
    end
    
    module Formatters
      class Null < LIBRARY::Formatter
        # Output nothing.
        tag 'null'
        
        def initialize(opts={})
        end
        
        def format(tokens, &b)
          tokens.each do |tok, val|
          end
          
          ''
        end
      end
      
      class Text < LIBRARY::Formatter
        # Output as plain text.
        tag 'text'
        
        def initialize(opts={})
        end
        
        def stream(tokens, &b)
          tokens.each do |tok, val|
            yield val
          end
        end
      end
    end
  end
end
