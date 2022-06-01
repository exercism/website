FactoryBot.define do
  factory :submission do
    uuid { SecureRandom.compact_uuid }
    solution { build :concept_solution, track: }
    submitted_via { "cli" }
    tests_status { :not_queued }

    transient do
      track do
        Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
      end
    end
  end
end
