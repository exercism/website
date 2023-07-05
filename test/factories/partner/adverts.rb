FactoryBot.define do
  factory :advert, class: "Partner::Advert" do
    partner { create :partner }
    url { SecureRandom.hex }
    base_text { "Try it" }
    emphasised_text { "It's great" }

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
