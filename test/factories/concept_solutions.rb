FactoryBot.define do
  factory :concept_solution do
    user { create :user }
    exercise { create :concept_exercise, track: track }

    transient do
      track do
        Track.find_by(slug: 'csharp') || create(:track, slug: 'csharp')
      end
    end
  end
end
