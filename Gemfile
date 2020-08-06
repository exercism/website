source 'https://rubygems.org'

ruby '2.6.6'

# Service/framework dependencies
gem 'rails', git: 'http://github.com/rails/rails.git', ref: "b39ea7cc3662345ad8efbe496db5ae594449f85f"
# gem 'rails', '~> 6.1.0.alpha'
gem 'mysql2', '>= 0.4.4'
gem 'puma', '~> 4.1'
gem 'redis', '~> 4.0'
gem 'aws-sdk-s3', '~> 1'
gem 'anycable-rails', '~> 0.6' # , "~> 1.0.0.rc1"

# Interaction gems
gem 'rugged' # Git
gem 'rest-client' # http

# General-purpose gems
gem 'mandate', '0.4.0.beta.1'

# Setup dependencies
gem 'exercism-config', '>= 0.35.0'
# gem 'exercism-config', path: '../exercism_config'
# gem 'bootsnap', '>= 1.4.2', require: false

# Model-level dependencies
gem 'image_processing', '~> 1.2'
gem 'delayed_job_active_record', '~> 4.1.4'

# View-level Dependencies
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'haml-rails', '~> 2.0'
gem 'commonmarker'
gem 'ansi-to-html'

# Let's be nice to Windows users
platforms :mingw, :mswin, :x64_mingw, :jruby do
  # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  gem 'tzinfo-data'
end

group :development, :test do
  #  gem 'pry'
  #  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'solargraph'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'mocha'
  gem 'simplecov', '~> 0.17.0', require: false
end
