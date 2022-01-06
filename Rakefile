# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'propshaft'

require_relative 'config/application'

def output_config_files
  config_dir = Rails.root / 'app' / 'javascript' / 'config'

  # Write the assets manifest to a JSON file to allow JS
  # to refer to the correct asset files
  File.write(
    config_dir / '.manifest.json',
    Propshaft::Assembly.new(Rails.application.config.assets).load_path.manifest
      .to_json
  )

  # Write a subset of the Exercism config settings to a JSON file
  # to allow using those settings in JS
  File.write(
    config_dir / 'config.json',
    Exercism.config.to_h.slice(:website_assets_host).to_json
  )
end

namespace :assets do
  task :config do
    output_config_files
    puts Exercism.config.mysql_port
  end
end

Rails.application.load_tasks

Rake::Task['javascript:build'].enhance(%w[assets:config])
