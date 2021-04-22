FactoryBot.define do
  factory :mentor_discussion, class: 'Mentor::Discussion' do
    mentor { create :user }
    request { create :mentor_request }
    solution { create :practice_solution, track: track }

    transient do
      track do
        Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
      end
    end

    trait :awaiting_student do
      status { :awaiting_student }
      awaiting_student_since { Time.current }
    end

    trait :awaiting_mentor do
      status { :awaiting_mentor }
      awaiting_mentor_since { Time.current }
    end

    trait :mentor_finished do
      status { :mentor_finished }
      finished_at { Time.current }
      finished_by { :mentor }
    end

    trait :student_finished do
      status { :finished }
      finished_at { Time.current }
      finished_by { :student }
    end
  end
end
