require "test_helper"

class AssembleJourneyOverviewTest < ActiveSupport::TestCase
  test "with new user" do
    user = create :user
    expected = {
      overview: {
        learning: {
          tracks: [],
          links: {
            solutions: Exercism::Routes.solutions_journey_url,
            fable: "#"
          }
        },
        mentoring: {
          tracks: [],
          totals: {
            discussions: 0,
            students: 0,
            ratio: 0
          },
          ranks: {
            discussions: nil,
            students: nil
          }
        },
        contributing: AssembleContributionsSummary.(user, for_self: true),
        badges: {
          badges: SerializeUserAcquiredBadges.(user.acquired_badges.revealed),
          links: {
            badges: Exercism::Routes.badges_journey_url
          }
        }
      }
    }

    assert_equal expected, AssembleJourneyOverview.(user)
  end

  test "with learning tracks" do
    track = create :track
    user = create :user
    user_track = create(:user_track, user:, track:)
    UserTrack.any_instance.expects(num_exercises: 10)
    UserTrack.any_instance.expects(num_completed_exercises: 5)
    UserTrack.any_instance.expects(num_concepts_learnt: 2)
    UserTrack.any_instance.expects(num_started_exercises: 7)

    expected = [{
      title: track.title,
      slug: track.slug,
      num_exercises: 10,
      num_completed_exercises: 5,
      num_concepts_learnt: 2,
      icon_url: track.icon_url,
      num_lines: 250,
      num_solutions: 7,
      started_at: user_track.created_at,
      num_completed_mentoring_discussions: 0,
      num_in_progress_mentoring_discussions: 0,
      num_queued_mentoring_requests: 0,
      progress_chart: {
        period: "Last 14 days",
        data: Array.new(14) { 0 }
      }
    }]

    assert_equal expected, AssembleJourneyOverview.(user)[:overview][:learning][:tracks]
  end

  test "progress charts - year" do
    track = create :track
    user = create :user
    create(:user_track, user:, track:)

    dates = []
    values = [1, 3, 4, 2, 1, 3, 4, 5, 2, 3, 5, 9]
    values.each.with_index do |value, idx|
      dates += value.times.map { (Time.current - (values.size - 1 - idx).months).to_i } # rubocop:disable Performance/TimesMap
    end
    UserTrack.any_instance.expects(exercise_completion_dates: dates).twice

    expected = {
      period: "Last 12 months",
      data: values
    }

    assert_equal expected, AssembleJourneyOverview.(user)[:overview][:learning][:tracks][0][:progress_chart]
  end

  test "progress charts - weeks (previous year has 52 weeks)" do
    travel_to(Date.new(2022, 1, 5))

    track = create :track
    user = create :user
    create(:user_track, user:, track:)

    # Create a dates array containing values for each period
    dates = []
    values = [1, 3, 4, 2, 1, 3, 2, 3, 5, 9]
    values.each.with_index do |value, idx|
      dates += value.times.map { (Time.current - (values.size - 1 - idx).weeks).to_i } # rubocop:disable Performance/TimesMap
    end
    UserTrack.any_instance.expects(exercise_completion_dates: dates).twice

    expected = {
      period: "Last 10 weeks",
      data: values
    }

    assert_equal expected, AssembleJourneyOverview.(user)[:overview][:learning][:tracks][0][:progress_chart]
  end

  test "progress charts - weeks (previous year has 53 weeks)" do
    travel_to(Date.new(2021, 1, 5))

    track = create :track
    user = create :user
    create(:user_track, user:, track:)

    # Create a dates array containing values for each period
    dates = []
    values = [1, 3, 4, 2, 1, 3, 2, 3, 5, 9]
    values.each.with_index do |value, idx|
      dates += value.times.map { (Time.current - (values.size - 1 - idx).weeks).to_i } # rubocop:disable Performance/TimesMap
    end
    UserTrack.any_instance.expects(exercise_completion_dates: dates).twice

    expected = {
      period: "Last 10 weeks",
      data: values
    }

    assert_equal expected, AssembleJourneyOverview.(user)[:overview][:learning][:tracks][0][:progress_chart]
  end

  test "progress charts - days (previous year has 365 days)" do
    travel_to(Date.new(2019, 1, 5))

    track = create :track
    user = create :user
    create(:user_track, user:, track:)

    # Create a dates array containing values for each period
    dates = []
    values = [1, 3, 4, 2, 1, 3, 2, 3, 5, 9, 3, 1, 2, 6]
    values.each.with_index do |value, idx|
      dates += value.times.map { (Time.current - (values.size - 1 - idx).days).to_i } # rubocop:disable Performance/TimesMap
    end
    UserTrack.any_instance.expects(exercise_completion_dates: dates).twice

    expected = {
      period: "Last 14 days",
      data: values
    }

    assert_equal expected, AssembleJourneyOverview.(user)[:overview][:learning][:tracks][0][:progress_chart]
  end

  test "progress charts - days (previous year has 366 days)" do
    travel_to(Date.new(2021, 1, 5))

    track = create :track
    user = create :user
    create(:user_track, user:, track:)

    # Create a dates array containing values for each period
    dates = []
    values = [1, 3, 4, 2, 1, 3, 2, 3, 5, 9, 3, 1, 2, 6]
    values.each.with_index do |value, idx|
      dates += value.times.map { (Time.current - (values.size - 1 - idx).days).to_i } # rubocop:disable Performance/TimesMap
    end
    UserTrack.any_instance.expects(exercise_completion_dates: dates).twice

    expected = {
      period: "Last 14 days",
      data: values
    }

    assert_equal expected, AssembleJourneyOverview.(user)[:overview][:learning][:tracks][0][:progress_chart]
  end

  test "with mentored tracks" do
    ruby = create :track, slug: :ruby
    js = create :track, slug: :js

    mentor = create :user
    student_1 = create :user
    student_2 = create :user
    create :mentor_discussion, mentor:, solution: create(:practice_solution, user: student_1, track: ruby)
    create :mentor_discussion, mentor:, solution: create(:practice_solution, user: student_1, track: js)
    create :mentor_discussion, mentor:, solution: create(:practice_solution, user: student_2, track: js)
    create :mentor_discussion, mentor:, solution: create(:practice_solution, user: student_1, track: js)

    # Unused records to ensure they're filtered
    create :mentor_discussion, solution: create(:practice_solution, user: student_2, track: js)
    create :track, slug: :csharp

    expected = {
      tracks: [{
        title: js.title,
        slug: js.slug,
        icon_url: js.icon_url,
        num_discussions: 3,
        num_students: 2
      }, {
        title: ruby.title,
        slug: ruby.slug,
        icon_url: ruby.icon_url,
        num_discussions: 1,
        num_students: 1
      }],
      totals: {
        discussions: 4,
        students: 2,
        ratio: 2
      },
      ranks: {
        discussions: nil,
        students: nil
      }
    }

    assert_equal expected, AssembleJourneyOverview.(mentor)[:overview][:mentoring]
  end

  test "mentoring" do
    track = create :track
    user = create :user
    create(:user_track, user:, track:)
    create :mentor_discussion, :awaiting_student, solution: create(:practice_solution, user:, track:)
    create :mentor_discussion, :awaiting_mentor, solution: create(:practice_solution, user:, track:)
    create :mentor_discussion, :mentor_finished, solution: create(:practice_solution, user:, track:)
    create :mentor_discussion, :student_finished, solution: create(:practice_solution, user:, track:)
    5.times { create :mentor_request, solution: create(:practice_solution, user:, track:) }

    data = AssembleJourneyOverview.(user)[:overview][:learning][:tracks][0]
    assert_equal 1, data[:num_completed_mentoring_discussions]
    assert_equal 3, data[:num_in_progress_mentoring_discussions]
    assert_equal 5, data[:num_queued_mentoring_requests]
  end
end
