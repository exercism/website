# We don't add URL as a global acronym because that would rename existing
# classes (Cloudflare::PurgeUrls et al), so we inflect the individual files.
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect("determine_url_for" => "DetermineURLFor")
end
