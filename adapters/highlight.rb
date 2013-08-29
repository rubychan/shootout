module Adapters
  class Highlight < ShootoutAdapter
    def installed?
      @installed ||= !`which highlightz`.empty?
    end
    
    def version
      installed? ? `highlight --version 2>&1`[/[\d.]+/] : 'n/a'
    end
    
    def name
      'highlight'
    end
    
    def highlight file, source, language, format
      return unless installed?
      return if format == 'null'
      return if format == 'text'
      
      format = 'ansi' if format == 'terminal'
      language = 'js' if language == 'json'
      
      `highlight -S #{language} -O #{format} -f -i #{file}`
    end
  end
end
