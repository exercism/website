require 'test_helper'

class SerializeExerciseAuthorshipsTest < ActiveSupport::TestCase
  test "n+1s handled correctly" do
    2.times do
      track = create :track, :random_slug
      exercise = create(:practice_exercise, :random_slug, track:)
      2.times do
        create :exercise_authorship, exercise:
      end
    end

    Bullet.profile do
      SerializeExerciseAuthorships.(Exercise.all)
    end
  end
end
