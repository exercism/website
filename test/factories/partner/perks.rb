FactoryBot.define do
  factory :perk, class: "Partner::Perk" do
    partner { create :partner }
    general_url { SecureRandom.hex }
    preview_text { "Try it" }
    general_offer_summary_markdown { "It's great" }
    general_button_text { "Click here" }
    general_offer_details { "Stuff here" }

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
