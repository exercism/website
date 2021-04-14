require_relative "../react_component_test_case"

module ReactComponents::Profile
  class ContributionsSummaryTest < ReactComponentTestCase
    test "mentoring solution renders correctly" do
      user = create :user

      elixir = create :track, slug: :elixir, title: "Elixir"
      js = create :track, slug: :js, title: "JavaScript"

      # Building tokens
      3.times { create :user_code_contribution_reputation_token, track: elixir, user: user }
      2.times { create :user_code_contribution_reputation_token, track: js, user: user }
      1.times { create :user_code_contribution_reputation_token, user: user } # rubocop:disable Lint/UselessTimes

      # Maintaining tokens
      4.times { create :user_code_review_reputation_token, track: elixir, user: user }
      3.times { create :user_code_review_reputation_token, track: js, user: user }
      2.times { create :user_code_review_reputation_token, user: user }

      # Contributing tokens
      5.times do
        exercise = create :practice_exercise, track: elixir
        contributorship = create(:exercise_contributorship, contributor: user, exercise: exercise)
        create :user_exercise_contribution_reputation_token, params: { contributorship: contributorship }, user: user
      end
      6.times do
        exercise = create :practice_exercise, track: js
        contributorship = create(:exercise_contributorship, contributor: user, exercise: exercise)
        create :user_exercise_contribution_reputation_token, params: { contributorship: contributorship }, user: user
      end

      # Published solutions tokens
      3.times { create :practice_solution, :published, track: elixir, user: user }
      2.times { create :practice_solution, :published, track: js, user: user }
      1.times { create :practice_solution, :published, user: user } # rubocop:disable Lint/UselessTimes

      # Mentoring discussions
      5.times { create :mentor_discussion, solution: create(:practice_solution, track: elixir), mentor: user }
      4.times { create :mentor_discussion, solution: create(:practice_solution, track: js), mentor: user }

      expected = {
        all: [
          # TODO: Reputation
          { id: :publishing, reputation: 0, metric: "6 solutions" },
          # TODO: Reputation
          { id: :mentoring, reputation: 0, metric: "9 students" },
          { id: :authoring, reputation: 110, metric: "11 exercises" },
          { id: :building, reputation: 72, metric: "6 PRs created" },
          { id: :maintaining, reputation: 45, metric: "9 PRs reviewed" },
          { id: :other, reputation: 0 }
        ],
        tracks: [
          {
            id: "elixir", title: "Elixir", icon_url: elixir.icon_url, categories: [
              # TODO: Reputation
              { id: :publishing, reputation: 0, metric: "3 solutions" },
              # TODO: Reputation
              { id: :mentoring, reputation: 0, metric: "5 students" },
              { id: :authoring, reputation: 50, metric: "5 exercises" },
              { id: :building, reputation: 36, metric: "3 PRs created" },
              { id: :maintaining, reputation: 20, metric: "4 PRs reviewed" },
              { id: :other, reputation: 0 }
            ]
          },
          {
            id: "js", title: "JavaScript", icon_url: js.icon_url, categories: [
              # TODO: Reputation
              { id: :publishing, reputation: 0, metric: "2 solutions" },
              # TODO: Reputation
              { id: :mentoring, reputation: 0, metric: "4 students" },
              { id: :authoring, reputation: 60, metric: "6 exercises" },
              { id: :building, reputation: 24, metric: "2 PRs created" },
              { id: :maintaining, reputation: 15, metric: "3 PRs reviewed" },
              { id: :other, reputation: 0 }
            ]
          }

        ]
      }
      component = ContributionsSummary.new(user)
      assert_equal expected, component.data
    end
  end
end
