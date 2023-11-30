require "test_helper"

class Badge::Completed12In23BadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :completed_12_in_23_badge
    assert_equal "Completed #12in23 Challenge", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :'badge-completed-12-in-23', badge.icon # rubocop:disable Naming/VariableNumber
    assert_equal 'Completed and published all featured exercises in the #12in23 challenge', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :completed_12_in_23_badge
    other_user = create :user

    refute badge.award_to?(user.reload)

    create :user_challenge, user:, challenge_id: '12in23'
    refute badge.award_to?(user.reload)

    User::Challenges::FeaturedExercisesProgress12In23.featured_exercises.values.flatten.uniq.each do |track_slug|
      create(:track, slug: track_slug)
    end

    User::Challenges::FeaturedExercisesProgress12In23.featured_exercises.each do |exercise_slug, track_slugs|
      track = Track.for!(track_slugs.sample)
      exercise = create(:practice_exercise, track:, slug: exercise_slug)
      create(:practice_solution, :published, user:, track:, exercise:,
        published_at: Time.utc(2023, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end

    assert badge.award_to?(user.reload)

    last_solution = user.solutions.last

    # Sanity check: only published solutions count
    last_solution.update(published_iteration_id: nil, published_at: nil)
    refute badge.award_to?(user.reload)

    # Sanity check: other user's solutions don't count
    create(:practice_solution, :published, user: other_user, track: last_solution.track, exercise: last_solution.exercise,
      published_at: Time.utc(2023, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload)
  end
end
