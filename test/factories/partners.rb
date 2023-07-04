FactoryBot.define do
  factory :partner do
    slug { "partner_#{SecureRandom.hex(4)}" }
    name { slug.to_s.titleize }
    website_url { "https://google.com" }
    support_markdown { "Paid a tons of money" }
    description_markdown { "# Hey" }

    light_logo do
      # Ensure we have a file with a different filename each time
      tempfile = Tempfile.new([SecureRandom.uuid, '.png'])
      tempfile.write(File.read(Rails.root.join("app", "images", "favicon.png")))
      tempfile.rewind

      Rack::Test::UploadedFile.new(tempfile.path, 'image/png')
    end

    dark_logo do
      # Ensure we have a file with a different filename each time
      tempfile = Tempfile.new([SecureRandom.uuid, '.png'])
      tempfile.write(File.read(Rails.root.join("app", "images", "favicon.png")))
      tempfile.rewind

      Rack::Test::UploadedFile.new(tempfile.path, 'image/png')
    end
  end
end
