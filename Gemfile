source 'https://rubygems.org'

ruby '3.1.0'

# Service/framework dependencies
gem 'rails', '~> 7.0.1'
gem 'cssbundling-rails'
gem 'jsbundling-rails'
gem 'turbo-rails'
gem 'propshaft', '0.4.0' # Changing this will break stuff. Work needed.

gem 'mysql2',
    github: 'brianmario/mysql2', ref: '56c0ced2afe2cabe0b3f1a05e8e5e86713ebbc87'
gem 'redis', '~> 4.0'
gem 'aws-sdk-s3', '~> 1'
gem 'aws-sdk-ecr'
gem 'anycable-rails', '~> 1.2.0'

# Serving requests
gem 'puma', '~> 4.3'
gem 'rack-cors'

# Helper gems for Rails
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bugsnag'

# Interaction gems
gem 'rugged' # Git
gem 'rest-client' # http
gem 'octokit' # GitHub

# General-purpose gems
gem 'mandate', '2.0.0'
gem 'kaminari'
gem 'oj'

# Setup dependencies
gem 'exercism-config', '>= 0.84.0' # gem 'exercism-config', path: '../exercism_config'

# Model-level dependencies
gem 'image_processing', '~> 1.2'
gem 'friendly_id', '~> 5.4.0'
gem 'sidekiq', '~> 6.3'
gem 'sidekiq-failures'
gem 'sidekiq-scheduler'

# View-level Dependencies
gem 'hamlit'
gem 'commonmarker'
gem 'ansi-to-html'

# Authentication
gem 'devise', '~> 4.7'

# Omniauth
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'

# Payments
gem 'stripe'

# Reporting
gem 'skylight'

gem 'listen', '>= 3.0.5', '< 3.2'

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
  gem 'webdrivers'
  gem 'webmock'
  gem 'show_me_the_cookies'

  # Adds assert_template
  gem 'rails-controller-testing'

  # Used for stripe mocking
  gem 'recursive-open-struct'
end

gem 'addressable', '~> 2.7'
gem 'mini_magick'

gem 'elasticsearch', '6.8.3'

gem 'rack-attack', '~> 6.6'
gem 'geocoder', '~> 1.8'
