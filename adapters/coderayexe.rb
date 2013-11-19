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
      if ENV['LOCAL_CODERAY']
        "#{fast_ruby} -I #{ENV['LOCAL_CODERAY']}/lib/coderay #{ENV['LOCAL_CODERAY']}/bin/coderay"
      else
        "#{fast_ruby} -S coderay #{"_#{ENV['CODERAY']}_" if ENV['CODERAY']}"
      end
    end
    
    def highlight file, source, language, format
      return unless installed?
      
      format = 'HTML' if format == 'html' && version >= '1.1.0'
      
      `#{executable} -#{language} #{file} -#{format}`
    end
  end
end
