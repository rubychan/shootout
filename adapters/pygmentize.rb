module Adapters
  class Pygmentize < ShootoutAdapter
    def installed?
      @installed ||= !`which pygmentize`.empty?
    end
    
    def version
      installed? ? `pygmentize -V 2>&1`[/[\d.]+/] : 'n/a'
    end
    
    def name
      'pygmentize'
    end
    
    def highlight file, source, language, format
      return unless installed?
      return if format == 'null'
      
      `pygmentize -l #{language} -f #{format} -O encoding=utf-8 #{file}`
    end
  end
end
