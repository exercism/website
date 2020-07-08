source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Service/framework dependencies
gem 'rails', github: 'rails/rails', branch: 'master' # , '~> 6.0.2', '>= 6.0.2.2'
gem 'mysql2', '>= 0.4.4'
gem 'puma', '~> 4.1'
gem 'redis', '~> 4.0'
gem 'aws-sdk-s3', '~> 1'
gem 'anycable-rails', '~> 0.6' # , "~> 1.0.0.rc1"

# Interaction gems
gem 'rugged' # Git
gem 'rest-client' # http

# General-purpose gems
gem 'mandate', github: 'ihid/mandate', branch: 'AndrewRadev-keyword-args'

# Setup dependencies
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
