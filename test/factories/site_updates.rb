FactoryBot.define do
  factory :site_update, class: "SiteUpdates::NewExerciseUpdate" do
    exercise { create :practice_exercise }
  end
end
