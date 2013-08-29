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
    REPEATS * source.size / Benchmark.realtime do
      REPEATS.times do
        highlight file, source, language, format
      end
    end
  end
  
  def highlight file, source, language, format
  end
end
