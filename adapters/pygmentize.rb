module Adapters
  class Pygmentize < ShootoutAdapter
    def version
      `pygmentize -V 2>&1`[/[\d.]+/]
    end
    
    def name
      'pygmentize'
    end
    
    def highlight file, source, language, format
      return if format == 'null'
      `pygmentize -l #{language} -f #{format} #{file}`
    end
  end
end
