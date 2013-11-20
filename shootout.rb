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
puts "  ~~~ The Great Syntax Highlighter Shootout v1.5 ~~~"
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
  
  LANGUAGES.each do |language|
    begin
      puts if SIZES.size == 1
      file = Pathname.glob(File.expand_path("../example-code/#{language}.*", __FILE__)).first
      raise "File not found: example-code/#{language}.*" unless file
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
          puts '%4s (%d kB, %d repeats)' % [language.upcase, source.size / 1000, repeats]
        else
          puts '%4s (%d repeats)' % [language.upcase, repeats]
        end
      else
        puts '%s (%d kB)' % [language.upcase, source.size / 1000]
      end
      
      for format in FORMATS
        print "\e[#{31 + FORMATS.index(format)}m"
        print '=> %-8s' % [format]
        for shooter in SHOOTER_ADAPTERS
          if time = shooter.benchmark(file, source, language, format, repeats, SET_GC == 'disable')
            if ENV['METRIC'] == 'time'
              print '%17.2f ms' % [time * 1000]
            else
              print '%15.0f kB/s' % [(source.size / time) / 1000]
            end
          else
            print ' ' * 20
          end
        end
        puts "\e[0m"
      end
    ensure
      size_file.delete if size_file
    end
  end
end
