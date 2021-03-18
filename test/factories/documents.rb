FactoryBot.define do
  factory :document do
    uuid { SecureRandom.uuid }
    slug { SecureRandom.uuid }
    git_repo { TestHelpers.git_repo_url("track-with-exercises") }
    git_path { "docs/TESTS.md" }
    title { "Running the Tests" }
  end
end
