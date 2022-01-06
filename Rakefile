# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'propshaft'

require_relative 'config/application'

namespace :erik do
  task :setup do
    ass = Propshaft::Assembly.new(Rails.application.config.assets)
    File.write(
      # Use app/javascript/config/.manifest.json
      Rails.root / 'app' / 'javascript' / '.manifest.json',
      ass.load_path.manifest.to_json
    )

    File.write(
      Rails.root / 'app' / 'javascript' / 'config.json',
      Exercism.config.to_h.slice(:website_assets_host).to_json
    )
  end
end

Rails.application.load_tasks

Rake::Task['css:build'].enhance(%w[erik:setup])
