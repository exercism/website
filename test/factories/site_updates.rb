FactoryBot.define do
  factory :site_update, class: "SiteUpdates::NewExerciseUpdate" do
    exercise { create :practice_exercise }
    track { exercise.track }
  end

  factory :new_exercise_site_update, class: "SiteUpdates::NewExerciseUpdate" do
    exercise { create :practice_exercise }
    track { exercise.track }
  end

  factory :new_concept_site_update, class: "SiteUpdates::NewConceptUpdate" do
    track { concept.track }
    params do
      {
        concept: create(:track_concept)
      }
    end
  end
end
