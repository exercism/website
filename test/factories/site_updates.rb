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
    params do
      {
        concept: create(:concept)
      }
    end
    track { concept.track }
  end

  factory :arbitrary_site_update, class: "SiteUpdates::ArbitraryUpdate" do
    author { create(:user) }
    track { create(:track) }
  end
end
