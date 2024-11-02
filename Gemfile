source 'https://rubygems.org'

if ENV['LOCAL_CODERAY']
  gem 'coderay', :path => ENV['LOCAL_CODERAY']
else
  gem 'coderay', ENV.fetch('CODERAY', '>= 1.1.1')
end

if ENV['LOCAL_ROUGE']
  gem 'rouge', :path => ENV['LOCAL_ROUGE']
else
  gem 'rouge', ENV.fetch('ROUGE', '>= 1.10.1')
end

gem 'pygments.rb', ENV.fetch('PYGMENTSRB', '>= 0.6.3')
