source 'https://rubygems.org'

ruby '3.3.0'

# Service/framework dependencies
gem 'rails', '~> 7.0.1'
gem 'cssbundling-rails'
gem 'jsbundling-rails'
gem 'turbo-rails'
gem 'propshaft', '0.4.0' # Changing this will break stuff. Work needed.

gem 'mysql2', '~> 0.5.6'
gem 'redis', '~> 4.0'
gem 'aws-sdk-s3', '~> 1'
gem 'aws-sdk-ecr'
gem 'aws-sdk-cloudfront'
gem 'aws-sdk-sesv2'
gem 'anycable-rails', '~> 1.2.0'
gem 'grpc', '>= 1.53.0'
gem 'crawler_detect'

# Serving requests
gem 'puma', '~> 4.3'
gem 'rack-cors'

# Helper gems for Rails
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bugsnag'

# Interaction gems
gem 'rugged'
gem 'rest-client' # http
gem 'octokit' # GitHub

# General-purpose gems
gem 'mandate', '~> 2.0'
gem 'kaminari'
gem 'oj', '~> 3.14.0'

# Setup dependencies
gem 'exercism-config', '>= 0.118.0' # gem 'exercism-config', path: '../config'

# Model-level dependencies
gem 'image_processing', '~> 1.2'
gem 'friendly_id', '~> 5.4.0'
gem 'sidekiq', '7.1.4'
gem 'sidekiq-failures'
gem 'sidekiq-scheduler'

# View-level Dependencies
gem 'hamlit'
gem 'commonmarker', '>= 0.23.8'
gem 'ansi-to-html'
gem 'public_suffix'
gem 'humanize'

# Authentication
gem 'devise', '~> 4.7'

# Omniauth
gem 'omniauth-github'
gem 'omniauth-discord'
gem 'omniauth-rails_csrf_protection'

# Payments
gem 'stripe'
gem 'coinbase_commerce', github: 'exercism/coinbase-commerce-ruby'

# Discourse
gem 'discourse_api'

# Performance issue Reporting
gem 'skylight'
gem 'bullet'

gem 'listen', '>= 3.0.5', '< 4.0'

# Let's be nice to Windows users
platforms :mingw, :mswin, :x64_mingw, :jruby do
  # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  gem 'tzinfo-data'
end

group :development, :test do
  #  gem 'pry'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'

  # To avoid polling for changes on Windows MRI, it needs this opt-in gem
  gem 'wdm', '>= 0.1.0' if Gem.win_platform?
end

group :development do
  gem 'haml_lint', require: false
  gem 'solargraph'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'minitest'
  gem 'minitest-retry'
  gem 'mocha'
  gem 'selenium-webdriver'
  gem 'webmock'
  gem 'show_me_the_cookies'

  # Adds assert_template
  gem 'rails-controller-testing'

  # Used for stripe mocking
  gem 'recursive-open-struct'
end

gem 'addressable', '~> 2.7'
gem 'mini_magick'

gem 'opensearch-ruby'

gem 'rack-attack', '~> 6.6'

gem 'geocoder', '~> 1.8'
gem 'maxminddb', '~> 0.1.22'

gem 'rubyzip', '~> 2.3'

gem 'toml', '~> 0.3.0'
gem 'ruby-openai'
