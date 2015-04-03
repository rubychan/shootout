#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.require

require 'benchmark'
require_relative 'shootout_adapter'

SHOOTERS  = ENV.fetch('SHOOTERS',  'CodeRay Rouge Pygments.rb').split
LANGUAGES = ENV.fetch('LANGUAGES') { Dir[File.expand_path('../example-code/*', __FILE__)].map { |path| File.basename path, '.*' }.sort.join(' ') }.split
FORMATS   = ENV.fetch('FORMATS',   'terminal html').split  # also available: null, text
REPEATS   = ENV.fetch('REPEATS',   5).to_i
SIZES     = Array(eval(ENV.fetch('SIZES', ENV.fetch('SIZE', '-1'))))
SET_GC    = ENV.fetch('GC', 'enable')

SHOOTERS.replace %w(CodeRay CodeRayExe Rouge Rougify Albino Pygments.rb Pygmentize Highlight) if SHOOTERS.first.downcase == 'all'
SHOOTER_ADAPTERS = ShootoutAdapter.load(SHOOTERS)

puts
puts "                       Welcome to"
puts "  ~~~ The Great Syntax Highlighter Shootout v1.6 ~~~"
puts
puts "using Ruby #{RUBY_VERSION} and Python #{`python -V 2>&1`[/[\d.]+/]}, repeating #{REPEATS} times"
puts

print '%11s' % ['']
for shooter in SHOOTER_ADAPTERS
  print '%20s' % "#{shooter.name} #{shooter.version}"
end

for size in SIZES
  if SIZES.size > 1
    puts
    if size < 0
      puts "using \e[34mthe whole file\e[0m" % [size]
    elsif size == 1
      puts "using \e[34m1 byte\e[0m"
    else
      puts "using \e[34m%d bytes\e[0m" % [size]
    end
    
    repeats = [REPEATS * SIZES.max / [size, 100].max, 1].max
  else
    repeats = REPEATS
  end
  
  scores = Hash.new { |h, k| h[k] = [] }
  
  LANGUAGES.each do |language|
    if scanner_version = language[/:(\d+)$/, 1]
      file_name = $`
      scanner = file_name + scanner_version
    else
      file_name = scanner = language
    end
    
    begin
      puts if SIZES.size == 1
      file = Pathname.glob(File.expand_path("../example-code/#{file_name}.*", __FILE__)).first
      raise "File not found: example-code/#{file_name}.*" unless file
      source = file.read
      
      if size >= 0
        source += source until source.size >= size
        source = source[0, size]
        size_file = Pathname.new file.to_s.sub(/\.\w+$/, "-#{size}")
        size_file.open('w') { |f| f.write source } unless size_file.exist?
        file = size_file
      end
      
      if SIZES.size > 1
        if size < 0
          puts '%4s (%d kB, %d repeats)' % [scanner.upcase, source.size / 1000, repeats]
        else
          puts '%4s (%d repeats)' % [scanner.upcase, repeats]
        end
      else
        puts '%s (%d kB)' % [scanner.upcase, source.size / 1000]
      end
      
      for format in FORMATS
        first_score = nil
        
        print "\e[#{31 + FORMATS.index(format)}m"
        print '=> %-8s' % [format]
        for shooter in SHOOTER_ADAPTERS
          if time = shooter.benchmark(file, source, scanner, format, repeats, SET_GC == 'disable')
            score = (source.size / time) / 1000
            first_score = score unless first_score
            scores[shooter.name] << score
            case ENV['METRIC']
            when 'time'
              print '%17.2f ms' % [time * 1000]
            when 'diff'
              print '%18.2f %%' % [score / first_score * 100]
            else
              print '%15.0f kB/s' % [score]
            end
          else
            scores[shooter.name] ||= []
            print ' ' * 20
          end
        end
        puts "\e[0m"
      end
    ensure
      size_file.delete if size_file
    end
  end
  
  puts '-' * (11 + 20 * scores.size)
  
  average_scores = {}
  for name, shooter_scores in scores
    if shooter_scores.empty?
      average_scores[name] = 0
    else
      average_scores[name] = shooter_scores.reduce(:+) / shooter_scores.size
    end
  end
  
  max_average_score = average_scores.values.max
  
  print '%-11s' % ["Total score"]
  for name, average_score in average_scores
    best = (average_score == max_average_score)
    print "\e[#{best ? 35 : 36}m%15.0f kB/s\e[0m" % [average_score]
  end
  puts
  
  print '%-11s' % ["Relative"]
  for name, average_score in average_scores
    if average_score == max_average_score
      print ' ' * 20
    else
      print "%18.2f %%" % [100 * average_score / max_average_score]
    end
  end
  puts
end
