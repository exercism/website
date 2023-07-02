FactoryBot.define do
  factory :perk, class: "Partner::Perk" do
    partner { create :partner }
    url { SecureRandom.hex }
    about_text { "Try it" }
    offer_markdown { "It's great" }
    button_text { "Click here" }

    logo do
      # Ensure we have a file with a different filename each time
      tempfile = Tempfile.new([SecureRandom.uuid, '.png'])
      tempfile.write(File.read(Rails.root.join("app", "images", "favicon.png")))
      tempfile.rewind

      Rack::Test::UploadedFile.new(tempfile.path, 'image/png')
    end
  end
end
FactoryBot.define do
  factory :partner_perk, class: 'Partner::Perk' do
  end
end
