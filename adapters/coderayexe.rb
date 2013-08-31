module Adapters
  class CodeRayExe < ShootoutAdapter
    def installed?
      @installed ||= !`which coderay`.empty?
    end
    
    def version
      @version ||= installed? ? `#{executable} --version 2>&1`[/[\d.]+/] : 'n/a'
    end
    
    def name
      'coderay'
    end
    
    def executable
      "#{fast_ruby} -I ../lib/coderay ../coderay/bin/coderay"
    end
    
    def highlight file, source, language, format
      return unless installed?
      format = 'HTML' if format == 'html' && version >= '1.1.0'
      `#{executable} -#{language} #{file} -#{format}`
    end
  end
end
