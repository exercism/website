FactoryBot.define do
  factory :mailshot do
    slug { SecureRandom.uuid }
    email_communication_preferences_key { :email_about_events }
    subject { "Be a badass" }
    button_url { "https://ihid.info" }
    button_text { "Some button text" }
    text_content { "Some textual content" }
    content_markdown { "Some content" }
  end
end
