#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.require

require 'benchmark'
require_relative 'shootout_adapter'

SHOOTERS  = ENV.fetch('SHOOTERS',  'CodeRay Rouge Pygmentize Pygments.rb Albino Highlight').split
LANGUAGES = ENV.fetch('LANGUAGES') { Dir[File.expand_path('../example-code/*', __FILE__)].map { |path| File.basename path, '.*' }.sort.join(' ') }.split
FORMATS   = ENV.fetch('FORMATS',   'text terminal html').split # "null" is not supported by Pygments
REPEATS   = ENV.fetch('REPEATS',   2).to_i

SHOOTER_ADAPTERS = ShootoutAdapter.load(SHOOTERS)

puts
puts "                       Welcome to"
puts "  ~~~ The Great Syntax Highlighter Shootout v1.0 ~~~"
puts
puts "using Ruby #{RUBY_VERSION} and Python #{`python -V 2>&1`[/[\d.]+/]}, repeating #{REPEATS} times"
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
        print ' ' * 20
      end
    end
    puts "\e[0m"
  end
end
