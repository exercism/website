FactoryBot.define do
  factory :document do
    uuid { SecureRandom.uuid }
    slug { SecureRandom.uuid }
    git_repo { TestHelpers.git_repo_url("track") }
    git_path { "docs/TESTS.md" }
    section { :contributing }
    title { "Running the Tests" }
  end

  trait :track do
    track { create :track }
  end
end
