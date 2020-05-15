FactoryBot.define do
  factory :track_concept, class: "Track::Concept" do
    track
    uuid { SecureRandom.uuid }
    name { "concept_#{SecureRandom.hex(4)}" }
  end
end
