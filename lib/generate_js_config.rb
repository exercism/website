module GenerateJSConfig
  def self.generate!
    write_manifest
    write_env
  end

  # Write the manifest to allow dynamically loading the images from JS
  # using the correct digest
  def self.write_manifest
    File.write(
      Rails.root / 'app' / 'javascript' / '.config' / 'manifest.json',
      Propshaft::Assembly.new(Rails.application.config.assets).load_path.manifest.
        to_json
    )
  end

  # Write a subset of the Exercism config settings to a JSON file
  # to allow using those settings in JS
  def self.write_env
    File.write(
      Rails.root / 'app' / 'javascript' / '.config' / 'env.json',
      Exercism.config.to_h.slice(:website_assets_host).to_json
    )
  end
end
