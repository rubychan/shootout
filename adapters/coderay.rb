module Adapters
  class CodeRay < ShootoutAdapter
    LIBRARY = ::CodeRay
    
    def highlight file, source, language, format
      return if language == 'perl'
      
      LIBRARY.encode(source, language, format)
    end
  end
end
