module Adapters
  class Albino < ShootoutAdapter
    LIBRARY = ::Albino
    
    def highlight file, source, language, format
      return if format == 'null'
      LIBRARY.colorize(source, language, format)
    end
  end
end
