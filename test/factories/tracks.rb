FactoryBot.define do
  factory :track do
    slug { "ruby" }
    title { slug.to_s.titleize }
    blurb { 'Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.' } # rubocop:disable Layout/LineLength
    repo_url { TestHelpers.git_repo_url("track") }
    synced_to_git_sha { "HEAD" }
    course { true }
    has_test_runner { true }
    has_representer { true }
    has_analyzer { true }

    trait :random_slug do
      slug { SecureRandom.hex }
    end
  end
end
