module Adapters
  class CodeRay < ShootoutAdapter
    LIBRARY = ::CodeRay

    def highlight file, source, language, format
      return if LIBRARY.scanner(language).is_a? LIBRARY::Scanners.default

      LIBRARY.encode(source, language, format)
    end
  end
end
