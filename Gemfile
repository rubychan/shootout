source 'https://rubygems.org'

if ENV['LOCAL_CODERAY']
  gem 'coderay', :path => ENV['LOCAL_CODERAY']
else
  gem 'coderay', ENV.fetch('CODERAY', '>= 1.1.0')
end

if ENV['LOCAL_ROUGE']
  gem 'rouge', :path => ENV['LOCAL_ROUGE']
else
  gem 'rouge', ENV.fetch('ROUGE', '>= 1.8.0')
end

gem 'pygments.rb', ENV.fetch('PYGMENTSRB', '>= 0.6.2')
gem 'albino',      ENV.fetch('ALBINO',     '>= 1.3.3')
