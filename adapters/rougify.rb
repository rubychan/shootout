module Adapters
  class Rougify < ShootoutAdapter
    def installed?
      @installed ||= !`which rougify`.empty?
    end
    
    def version
      @version ||= installed? ? `gem li rouge`[/\b\d+\.\d+\.\d+(?!\.)/] : 'n/a'
    end
    
    def name
      'rougify'
    end
    
    def executable
      if ENV['LOCAL_ROUGE']
        "#{fast_ruby} -I ../rouge/lib/rouge ../rouge/bin/rougify"
      else
        "#{fast_ruby} -S rougify _#{ENV['ROUGE']}_"
      end
    end
    
    def highlight file, source, language, format
      return unless installed?
      return if format == 'null'
      return if format == 'text'
      
      format = 'terminal256' if format == 'terminal'
      
      `#{executable} highlight -l #{language} -f #{format} #{file}`
    end
  end
end
