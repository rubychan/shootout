require 'pygments/version'

module Adapters
  class Pygmentsrb < ShootoutAdapter
    LIBRARY = ::Pygments
    
    def highlight file, source, language, format
      return if format == 'null'
      LIBRARY.highlight(source, lexer: language, formatter: format)
    end
  end
end
