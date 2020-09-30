FactoryBot.define do
  factory :track_concept, class: "Track::Concept" do
    track
    uuid { SecureRandom.uuid }
    slug { "concept_#{SecureRandom.hex(4)}" }
    name { slug.titleize }
  end
end
