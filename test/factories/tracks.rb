FactoryBot.define do
  factory :track do
    slug { "ruby" }
    title { 'Ruby' }
    repo_url { TestHelpers.git_repo_url("v3-monorepo") }

    # TODO: Readd these when we move away from monorepo
    # At the moment they need to be hardcoded as they are
    # above to match git
    # repo_url { TestHelpers.git_repo_url("track-with-exercises") }
    # slug { "slug_#{SecureRandom.hex(4)}" }
  end
end
