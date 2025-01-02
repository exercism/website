require "test_helper"

class Badge::LarisaLatyninaBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :larisa_latynina_badge
    assert_equal "Larisa Latynina", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'larisa-latynina', badge.icon
    assert_equal 'Earned 48 medals in the #48in24 challenge', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    badge = create :larisa_latynina_badge
    exercises = User::Challenges::FeaturedExercisesProgress48In24::EXERCISES
    week_1 = exercises.find { |e| e[:week] == 1 }
    tracks = exercises.map { |e| e[:featured_tracks] }.flatten.uniq.
      map { |track_slug| [track_slug.to_sym, create(:track, slug: track_slug)] }.
      to_h
    user = create :user

    # No solutions
    create :user_challenge, user:, challenge_id: '48in24'
    refute badge.award_to?(user.reload), "new user has no medals"

    # One bronze all year
    exercise = create(:practice_exercise, track: tracks[:csharp], slug: week_1[:slug])
    create(:practice_solution, :published, user:, track: tracks[:csharp], exercise:,
      completed_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload), "one bronze does not qualify"

    # One silver medal: csharp+tcl+wren are never the featured tracks for an exercise
    %i[tcl wren].each do |track_slug|
      exercise = create(:practice_exercise, track: tracks[track_slug], slug: week_1[:slug])
      create(:practice_solution, :published, user:, track: tracks[track_slug], exercise:,
        completed_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end
    refute badge.award_to?(user.reload), "one silver does not qualify"

    # One gold medal
    week_1[:featured_tracks].each do |track_slug|
      exercise = create(:practice_exercise, track: tracks[track_slug.to_sym], slug: week_1[:slug])
      create(:practice_solution, :published, user:, track: tracks[track_slug.to_sym], exercise:,
        completed_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end
    refute badge.award_to?(user.reload), "one gold does not qualify"

    # in addition to week 1 gold, add 46 bronze medals: 47 medals does not qualify
    exercises.reject { |e| e[:week] == 1 || e[:week] == 48 }.each do |e|
      exercise = create(:practice_exercise, track: tracks[:csharp], slug: e[:slug])
      create(:practice_solution, :published, user:, track: tracks[:csharp], exercise:,
        completed_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end
    refute badge.award_to?(user.reload), "47 medals does not qualify"

    # add week 48 solution, not in 2024
    week_48 = exercises.find { |e| e[:week] == 48 }
    exercise = create(:practice_exercise, track: tracks[:csharp], slug: week_48[:slug])
    solution = create(:practice_solution, :published, user:, track: tracks[:csharp], exercise:,
      completed_at: Time.utc(2023, SecureRandom.rand(1..11), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload), "47 medals plus one solution in 2023 does not qualify"

    # change completion date to 2024 to qualify
    solution.update(completed_at: Time.utc(2024, 1, 1, 0, 0, 0))
    assert badge.award_to?(user.reload), "48 bronzes qualifies"

    # 48 gold or silver medals
    exercises.reject { |e| e[:week] == 1 }.each do |e|
      %i[tcl wren].each do |t|
        exercise = create(:practice_exercise, track: tracks[t], slug: e[:slug])
        create(:practice_solution, :published, user:, track: tracks[t], exercise:,
          completed_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
      end
    end
    assert badge.award_to?(user.reload), "48 golds&silvers qualifies"

    # 48 gold medals
    exercises.reject { |e| e[:week] == 1 }.each do |e|
      e[:featured_tracks].map(&:to_sym).each do |t|
        next if %i[csharp tcl wren].include?(t) # already have these

        exercise = create(:practice_exercise, track: tracks[t], slug: e[:slug])
        create(:practice_solution, :published, user:, track: tracks[t], exercise:,
          completed_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
      end
    end
    assert badge.award_to?(user.reload), "48 golds qualifies"
  end
end
