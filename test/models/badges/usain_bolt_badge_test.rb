require "test_helper"

class Badges::UsainBoltBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :usain_bolt_badge
    assert_equal "Usain Bolt", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :'usain-bolt', badge.icon
    assert_equal 'Earned 48 gold medals in the #48in24 challenge', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    badge = create :usain_bolt_badge
    exercises = User::Challenges::FeaturedExercisesProgress48In24.EXERCISES
    week1 = exercises.select {|e| e[:week] == 1}
    tracks = exercises.map {|e| e[:featured_tracks]}.flatten.uniq
                       map {|track_slug| [track_slug.to_sym, create(:track, slug: track_slug)]}
                      .to_h
    user = create :user

    # No solutions
    refute badge.award_to?(user.reload)

    create :user_challenge, user:, challenge_id: '48in24'
    refute badge.award_to?(user.reload)

    # One bronze all year
    exercise = create(:practice_exercise, track: track[:csharp], slug: week1[:slug])
    create(:practice_solution, :published, user:, track: track[:csharp], exercise:,
      published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))

    refute badge.award_to?(user.reload)

    # One silver medal: csharp+tcl+wren are never the featured tracks for an exercise
    [:tcl, :wren].each do |track_slug|
      exercise = create(:practice_exercise, track: track[track_slug], slug: week1[:slug])
      create(:practice_solution, :published, user:, track: track[track_slug], exercise:,
        published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end

    refute badge.award_to?(user.reload)

    # One gold medal
    week1[:featured_tracks].each do |track_slug|
      create(:practice_solution, :published, user:, track: track[track_slug.to_sym], exercise:,
        published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end

    refute badge.award_to?(user.reload)

    # in addition to week 1 gold, add 46 bronze medals: 47 medals does not qualify
    exercises.select {|e| !(e[:week] == 1 || e[:week] == 48)}.each do |e|
      exercise = create(:practice_exercise, track: track[:csharp], slug: e[:slug])
      create(:practice_solution, :published, user:, track: track[:csharp], exercise:,
        published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end

    refute badge.award_to?(user.reload)

    # add week 48 solution, not in 2024
    week48 = exercises.select {|e| e[:week] == 48}
    exercise = create(:practice_exercise, track: track[:csharp], slug: week48[:slug])
    solution = create(:practice_solution, :published, user:, track: track[:csharp], exercise:,
      published_at: Time.utc(2023, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))

    refute badge.award_to?(user.reload)

    # add an iteration to week 48 to qualify
    iteration = create(:iteration, solution:)
    iteration.update(created_at: Time.utc(2024, 1, 1, 0, 0, 0)

    assert badge.award_to?(user.reload)

    # 48 gold or silver medals
    exercises.select {|e| !(e[:week] == 1}.each do |e|
      [:tcl, :wren].each do |t|
        exercise = create(:practice_exercise, track: track[t], slug: e[:slug])
        create(:practice_solution, :published, user:, track: track[t], exercise:,
          published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
      end
    end

    refute badge.award_to?(user.reload)

    # 48 gold medals
    exercises.select {|e| !(e[:week] == 1}.each do |e|
      e[:featured_tracks].map(&:to_sym).each do |t|
        next if [:csharp, :tcl, :wren].contains(t)  # already have these

        exercise = create(:practice_exercise, track: track[t], slug: e[:slug])
        create(:practice_solution, :published, user:, track: track[t], exercise:,
          published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
      end
    end

    assert badge.award_to?(user.reload)
  end
end
