FactoryBot.define do
  factory :track do
    slug { "slug_#{SecureRandom.hex(4)}" }
    title { 'Ruby' }
    repo_url { TestHelpers.git_repo_url("v3-monorepo") }

    # TODO: Readd this when we move away from monorepo
    # repo_url { TestHelpers.git_repo_url("track-with-exercises") }
  end
end
