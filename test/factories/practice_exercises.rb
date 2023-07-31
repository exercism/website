FactoryBot.define do
  factory :practice_exercise do
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end

    uuid { SecureRandom.uuid }
    slug { 'bob' }
    blurb { 'Hey Bob!' }
    title { slug.to_s.titleize }
    icon_name { 'bob' }
    position { 1 }
    status { :active }
    git_sha { "HEAD" }
    synced_to_git_sha { "HEAD" }
    git_important_files_hash { "b72b0958a135cddd775bf116c128e6e859bf11e4" }
    has_test_runner { true }

    trait :random_slug do
      slug { SecureRandom.hex }
      git_important_files_hash { SecureRandom.hex }
    end

    factory :hello_world_exercise do
      slug { "hello-world" }
      title { "Hello, World!" }
    end
  end
end
