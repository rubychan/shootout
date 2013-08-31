module Adapters
  class Rougify < ShootoutAdapter
    def installed?
      @installed ||= !`which rougify`.empty?
    end
    
    def version
      @version ||= installed? ? `#{executable} --version 2>&1`[/[\d.]+/] : 'n/a'
    end
    
    def name
      'rougify'
    end
    
    def executable
      "#{fast_ruby} -I ../lib/rouge ../rouge/bin/rougify"
    end
    
    def highlight file, source, language, format
      return unless installed?
      return if format == 'null'
      return if format == 'text'
      return if format == 'terminal'
      `#{executable} highlight -l #{language} -f #{format} #{file}`
    end
  end
end
