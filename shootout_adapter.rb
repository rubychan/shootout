require 'bundler/setup'
Bundler.require

require 'benchmark'

class ShootoutAdapter
  def self.load libraries
    libraries.map do |library|
      library = library.gsub(/\W/, '')
      require_relative "adapters/#{library.downcase}"
      Adapters.const_get(library).new
    end
  end
  
  def library
    self.class::LIBRARY
  end
  
  def version
    library::VERSION
  end
  
  def name
    library.name
  end
  
  def benchmark file, source, language, format
    # warmup and check
    unless highlight file, 'test', language, format
      return
    end
    
    # benchmark
    n * source.size / Benchmark.realtime do
      result = nil
      n.times do
        result = highlight file, source, language, format
      end
      if ENV['DEBUG'] == name
        puts
        puts result[/(?:.*\n){5}/], "\e[0m"
      end
    end
  end
  
  def highlight file, source, language, format
  end
  
  def n
    ENV.fetch('N', 4).to_i
  end
end
