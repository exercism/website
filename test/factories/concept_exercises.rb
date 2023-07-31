FactoryBot.define do
  factory :concept_exercise do
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end

    uuid { SecureRandom.uuid }
    slug { 'strings' }
    blurb { 'strings are super useful' }
    title { slug.to_s.titleize }
    icon_name { 'strings' }
    position { 1 }
    status { :active }
    git_sha { "HEAD" }
    synced_to_git_sha { "HEAD" }
    git_important_files_hash { "8616633f014000efd5b7d447b772c307d0a7cc49" }
    has_test_runner { true }

    trait :random_slug do
      slug { SecureRandom.hex }
      git_important_files_hash { SecureRandom.hex }
    end
  end
end
