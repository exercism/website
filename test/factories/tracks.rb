FactoryBot.define do
  factory :track do
    slug { "ruby" }
    title { slug.to_s.titleize }
    blurb { 'Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.' } # rubocop:disable Layout/LineLength
    repo_url { TestHelpers.git_repo_url("v3-monorepo") }
    synced_to_git_sha { "HEAD" }

    # TODO: Readd these when we move away from monorepo
    # At the moment they need to be hardcoded as they are
    # above to match git
    # repo_url { TestHelpers.git_repo_url("track-with-exercises") }
    # slug { "slug_#{SecureRandom.hex(4)}" }

    trait :random_slug do
      slug { SecureRandom.hex }
    end
  end
end
