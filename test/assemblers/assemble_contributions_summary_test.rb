require "test_helper"

class AssembleContributionsSummaryTest < ActiveSupport::TestCase
  test "renders correctly with data" do
    user = create :user

    js = create :track, slug: :js, title: "JavaScript"
    elixir = create :track, slug: :elixir, title: "Elixir"

    # Building tokens
    3.times { create :user_code_contribution_reputation_token, track: elixir, user: }
    2.times { create :user_code_contribution_reputation_token, track: js, user: }
    1.times { create :user_code_contribution_reputation_token, user: } # rubocop:disable Lint/UselessTimes

    # Maintaining tokens
    4.times { create :user_code_review_reputation_token, track: elixir, user: }
    3.times { create :user_code_review_reputation_token, track: js, user: }
    2.times { create :user_code_review_reputation_token, user: }

    # Contributing tokens
    5.times do
      exercise = create :practice_exercise, track: elixir
      contributorship = create(:exercise_contributorship, contributor: user, exercise:)
      create :user_exercise_contribution_reputation_token, params: { contributorship: }, user:
    end

    6.times do
      exercise = create :practice_exercise, track: js
      contributorship = create(:exercise_contributorship, contributor: user, exercise:)
      create :user_exercise_contribution_reputation_token, params: { contributorship: }, user:
    end

    # Published solutions tokens
    2.times do
      solution = create(:practice_solution, :published, track: js, user:)
      create :user_published_solution_reputation_token, params: { solution: }, user:
    end
    3.times do
      solution = create(:practice_solution, :published, track: elixir, user:)
      create :user_published_solution_reputation_token, params: { solution: }, user:
    end

    # Mentoring discussions
    4.times do
      discussion = create(:mentor_discussion, :student_finished, mentor: user, track: js)
      create :user_mentored_reputation_token, params: { discussion: }, user:
    end
    5.times do
      discussion = create(:mentor_discussion, :student_finished, mentor: user, track: elixir)
      create :user_mentored_reputation_token, params: { discussion: }, user:
    end

    create(:user_arbitrary_reputation_token, user:)
    create(:user_arbitrary_reputation_token, user:)

    generate_reputation_periods!

    expected = {
      tracks: [
        {
          slug: nil,
          title: "All Tracks",
          icon_url: nil,
          categories: [
            { id: :publishing, reputation: 10, metric_full: "5 solutions published", metric_short: "5 solutions" },
            { id: :mentoring, reputation: 45, metric_full: "9 students mentored", metric_short: "9 students" },
            { id: :authoring, reputation: 110, metric_full: "11 exercises contributed", metric_short: "11 exercises" },
            { id: :building, reputation: 72, metric_full: "6 PRs accepted", metric_short: "6 PRs accepted" },
            { id: :maintaining, reputation: 45, metric_full: "9 PRs reviewed", metric_short: "9 PRs reviewed" },
            { id: :other, reputation: 46 }
          ]
        },
        {
          slug: "elixir", title: "Elixir", icon_url: elixir.icon_url, categories: [
            { id: :publishing, reputation: 6, metric_full: "3 solutions published", metric_short: "3 solutions" },
            { id: :mentoring, reputation: 25, metric_full: "5 students mentored", metric_short: "5 students" },
            { id: :authoring, reputation: 50, metric_full: "5 exercises contributed", metric_short: "5 exercises" },
            { id: :building, reputation: 36, metric_full: "3 PRs accepted", metric_short: "3 PRs accepted" },
            { id: :maintaining, reputation: 20, metric_full: "4 PRs reviewed", metric_short: "4 PRs reviewed" },
            { id: :other, reputation: 0 }
          ]
        },
        {
          slug: "js", title: "JavaScript", icon_url: js.icon_url, categories: [
            { id: :publishing, reputation: 4, metric_full: "2 solutions published", metric_short: "2 solutions" },
            { id: :mentoring, reputation: 20, metric_full: "4 students mentored", metric_short: "4 students" },
            { id: :authoring, reputation: 60, metric_full: "6 exercises contributed", metric_short: "6 exercises" },
            { id: :building, reputation: 24, metric_full: "2 PRs accepted", metric_short: "2 PRs accepted" },
            { id: :maintaining, reputation: 15, metric_full: "3 PRs reviewed", metric_short: "3 PRs reviewed" },
            { id: :other, reputation: 0 }
          ]
        }

      ],
      handle: user.handle,
      links: {
        contributions: Exercism::Routes.contributions_profile_url(user.handle)
      }
    }

    assert_equal expected, AssembleContributionsSummary.(user, for_self: false)
  end

  test "renders correctly with no data" do
    user = create :user

    expected = {
      tracks: [
        {
          slug: nil,
          title: "All Tracks",
          icon_url: nil,
          categories: [
            { id: :publishing, reputation: 0, metric_full: "No solutions published", metric_short: "No solutions" },
            { id: :mentoring, reputation: 0, metric_full: "No students mentored", metric_short: "No students" },
            { id: :authoring, reputation: 0, metric_full: "No exercises contributed", metric_short: "No exercises" },
            { id: :building, reputation: 0, metric_full: "No PRs accepted", metric_short: "No PRs accepted" },
            { id: :maintaining, reputation: 0, metric_full: "No PRs reviewed", metric_short: "No PRs reviewed" },
            { id: :other, reputation: 0 }
          ]
        }
      ],
      handle: user.handle,
      links: {
        contributions: Exercism::Routes.contributions_profile_url(user.handle)
      }
    }

    assert_equal expected, AssembleContributionsSummary.(user, for_self: false)
  end
end
