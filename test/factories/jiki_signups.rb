FactoryBot.define do
  factory :jiki_signup do
    user
    preferred_locale { 'en' }
    preferred_programming_language { 'javascript' }
  end
end
