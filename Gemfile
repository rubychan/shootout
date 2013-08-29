source 'https://rubygems.org'

gem 'coderay',     ENV.fetch('CODERAY',    '1.0.9')
gem 'rouge',       ENV.fetch('ROUGE',      '0.4.0')
gem 'pygments.rb', ENV.fetch('PYGMENTSRB', '0.5.2')
gem 'albino',      ENV.fetch('ALBINO',     '1.3.3')

warn "!!! Make sure you install Pygments with: easy_install pygments"   if `which pygmentize`.chomp.empty?
warn "!!! Make sure you install highlight with: brew install highlight" if `which highlights`.chomp.empty?
