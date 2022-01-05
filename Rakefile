# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

namespace :erik do
  task :setup do
    puts `cp public/assets/.manifest.json app/javascript/.manifest.json`
  end
end

Rails.application.load_tasks

Rake::Task['javascript:build'].enhance(%w[erik:setup])
