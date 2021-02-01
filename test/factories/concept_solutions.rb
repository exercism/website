FactoryBot.define do
  factory :concept_solution do
    user { create :user }
    exercise { create :concept_exercise, track: track }

    transient do
      track do
        Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
      end
    end
  end
end
