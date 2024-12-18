require "test_helper"

class Badge::PaavoNurmiBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :paavo_nurmi_badge
    assert_equal "Paavo Nurmi", badge.name
    assert_equal :ultimate, badge.rarity
    assert_equal :'paavo-nurmi', badge.icon
    assert_equal 'Earned 48 gold or silver medals in the #48in24 challenge', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    badge = create :paavo_nurmi_badge
    exercises = User::Challenges::FeaturedExercisesProgress48In24::EXERCISES
    week_1 = exercises.find { |e| e[:week] == 1 }
    tracks = exercises.map { |e| e[:featured_tracks] }.flatten.uniq.
      map { |track_slug| [track_slug.to_sym, create(:track, slug: track_slug)] }.
      to_h
    user = create :user

    # No solutions
    refute badge.award_to?(user.reload)

    create :user_challenge, user:, challenge_id: '48in24'
    refute badge.award_to?(user.reload)

    # One bronze all year
    exercise = create(:practice_exercise, track: tracks[:csharp], slug: week_1[:slug])
    create(:practice_solution, :published, user:, track: tracks[:csharp], exercise:,
      published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload)

    # One silver medal: csharp+tcl+wren are never the featured tracks for an exercise
    %i[tcl wren].each do |track_slug|
      exercise = create(:practice_exercise, track: tracks[track_slug], slug: week_1[:slug])
      create(:practice_solution, :published, user:, track: tracks[track_slug], exercise:,
        published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end
    refute badge.award_to?(user.reload)

    # One gold medal
    week_1[:featured_tracks].each do |track_slug|
      exercise = create(:practice_exercise, track: tracks[track_slug.to_sym], slug: week_1[:slug])
      create(:practice_solution, :published, user:, track: tracks[track_slug.to_sym], exercise:,
        published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end
    refute badge.award_to?(user.reload)

    # in addition to week 1 gold, add 46 bronze medals: 47 medals does not qualify
    exercises.reject { |e| e[:week] == 1 || e[:week] == 48 }.each do |e|
      exercise = create(:practice_exercise, track: tracks[:csharp], slug: e[:slug])
      create(:practice_solution, :published, user:, track: tracks[:csharp], exercise:,
        published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end
    refute badge.award_to?(user.reload)

    # add week 48 solution, not in 2024
    week_48 = exercises.find { |e| e[:week] == 48 }
    exercise = create(:practice_exercise, track: tracks[:csharp], slug: week_48[:slug])
    solution = create(:practice_solution, :published, user:, track: tracks[:csharp], exercise:,
      published_at: Time.utc(2023, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload)

    # add an iteration to week 48
    iteration = create(:iteration, solution:)
    iteration.update(created_at: Time.utc(2024, 1, 1, 0, 0, 0))
    refute badge.award_to?(user.reload)

    # 48 gold or silver medals
    exercises.reject { |e| e[:week] == 1 }.each do |e|
      %i[tcl wren].each do |t|
        exercise = create(:practice_exercise, track: tracks[t], slug: e[:slug])
        create(:practice_solution, :published, user:, track: tracks[t], exercise:,
          published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
      end
    end
    assert badge.award_to?(user.reload)

    # 48 gold medals
    exercises.reject { |e| e[:week] == 1 }.each do |e|
      e[:featured_tracks].map(&:to_sym).each do |t|
        next if %i[csharp tcl wren].include?(t) # already have these

        exercise = create(:practice_exercise, track: tracks[t], slug: e[:slug])
        create(:practice_solution, :published, user:, track: tracks[t], exercise:,
          published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
      end
    end
    assert badge.award_to?(user.reload)
  end
end
