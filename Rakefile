SHOOTERS  = ENV.fetch('SHOOTERS',  'CodeRay Rouge Pygmentize Pygments.rb Albino Highlight').split
LANGUAGES = ENV.fetch('LANGUAGES', 'json ruby html').split
FORMATS   = ENV.fetch('FORMATS',   'text terminal html').split # "null" is not supported by Pygments

task :shooters do
  require_relative 'shootout_adapter'
  SHOOTER_ADAPTERS = ShootoutAdapter.load(SHOOTERS)
end

task :shootout => :shooters do
  puts
  puts "                    Welcome to"
  puts "  ~~~ The Great Syntax Highlighter Shootout ~~~"
  puts "                       v1.0"
  puts
  puts "using Ruby #{RUBY_VERSION} and Python #{`python -V 2>&1`[/[\d.]+/]}"
  puts
  
  print '%11s' % ['']
  for shooter in SHOOTER_ADAPTERS
    print '%20s' % "#{shooter.name} #{shooter.version}"
  end
  
  for language in LANGUAGES
    puts
    file = Pathname.glob(File.expand_path("../example-code/#{language}.*", __FILE__)).first
    source = file.read
    puts '%4s (%d kB)' % [language.upcase, source.size / 1000]
    for format in FORMATS
      print "\e[#{31 + FORMATS.index(format)}m"
      print '=> %-8s' % [format]
      for shooter in SHOOTER_ADAPTERS
        if time = shooter.benchmark(file, source, language, format)
          print '%15.0f kB/s' % [time / 1000]
        else
          print '%15s  N/A' % ['']
        end
      end
      puts "\e[0m"
    end
  end
end

task :default => :shootout
