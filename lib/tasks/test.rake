namespace :test do
  desc 'Initiate exercism website'
  task zeitwerk: :environment do
    Rails.application.eager_load!
    puts 'Successfully loaded Rails. Zeitwerk is happy'
  end
end
