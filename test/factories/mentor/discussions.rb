FactoryBot.define do
  factory :mentor_discussion, class: 'Mentor::Discussion' do
    mentor { create :user }
    solution { create :practice_solution, track:, exercise: }
    request { create :mentor_request, solution:, status: :fulfilled }

    transient do
      track do
        Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
      end
      exercise { create :practice_exercise, track: }
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

    trait :student_timed_out do
      status { :student_timed_out }
    end

    trait :mentor_timed_out do
      status { :mentor_timed_out }
    end

    trait :external do
      external { true }
      request { create :mentor_request, :external, solution:, status: :fulfilled }
    end
  end
end
