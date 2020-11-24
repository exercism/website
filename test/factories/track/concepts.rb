FactoryBot.define do
  factory :track_concept, class: "Track::Concept" do
    track
    uuid { SecureRandom.uuid }
    slug { "concept_#{SecureRandom.hex(4)}" }
    name { slug.titleize }
    blurb { "A cracking concept" }
    synced_to_git_sha { "HEAD" }

    trait :with_git_data do
      track { create(:track, slug: "csharp") }
      slug { "datetimes" }
    end
  end
end
