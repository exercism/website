FactoryBot.define do
  factory :generic_exercise do
    slug { "anagram" }
    title { "Anagram" }
    blurb { "Given a word and a list of possible anagrams, select the correct sublist." }
    source { "Inspired by the Extreme Startup game" }
    source_url { "https://github.com/rchatley/extreme_startup" }
    status { :active }

    trait :random_slug do
      slug { SecureRandom.hex }
      title { slug.titleize }
    end
  end
end
