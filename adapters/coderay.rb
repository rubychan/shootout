module Adapters
  class CodeRay < ShootoutAdapter
    LIBRARY = ::CodeRay
    
    def highlight file, source, language, format
      LIBRARY.encode(source, language, format)
    end
  end
end
