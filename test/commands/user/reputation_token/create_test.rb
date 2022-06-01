require "test_helper"

class User::ReputationToken::CreateTest < ActiveSupport::TestCase
  test "triggers reputation period creation on new" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user

    User::ReputationPeriod::MarkForToken.expects(:call)

    2.times do
      User::ReputationToken::Create.(
        user,
        :exercise_contribution, {
          contributorship:
        }
      )
    end
  end

  test "does not create reputation token for system user" do
    user = create :user, :system
    contributorship = create :exercise_contributorship, contributor: user

    User::ReputationToken::Create.(
      user,
      :exercise_contribution, {
        contributorship:
      }
    )

    refute User::ReputationToken.exists?
  end

  test "does not create reputation token for ghost user" do
    user = create :user, :ghost
    contributorship = create :exercise_contributorship, contributor: user

    User::ReputationToken::Create.(
      user,
      :exercise_contribution, {
        contributorship:
      }
    )

    refute User::ReputationToken.exists?
  end

  test "idempotent" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user

    assert_idempotent_command do
      User::ReputationToken::Create.(
        user,
        :exercise_contribution, {
          contributorship:
        }
      )
    end
  end

  test "awards contributor token if category is authoring" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user

    # The exercise contribution reputation token's category is authoring
    User::ReputationToken::Create.(user, :exercise_contribution, { contributorship: })

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::ContributorBadge
  end

  test "awards contributor token if category is building" do
    user = create :user, handle: "User22", github_username: "user22"

    # The code contribution reputation token's category is building
    User::ReputationToken::Create.(
      user,
      :code_contribution,
      repo: 'exercism/ruby',
      level: :large,
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: 'The cat sat on the mat',
      merged_at: Time.parse('2020-04-03T14:54:57Z').utc,
      external_url: 'https://api.github.com/repos/exercism/v3/pulls/1347'
    )

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::ContributorBadge
  end

  test "awards contributor token if category is maintaining" do
    user = create :user, handle: "User22", github_username: "user22"

    # The code merge reputation token's category is maintaining
    User::ReputationToken::Create.(
      user,
      :code_merge,
      repo: 'exercism/ruby',
      level: :janitorial,
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: 'The cat sat on the mat',
      merged_at: Time.parse('2020-04-03T14:54:57Z').utc,
      external_url: 'https://api.github.com/repos/exercism/v3/pulls/1347'
    )

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::ContributorBadge
  end

  test "awards contributor token if category is mentoring" do
    user = create :user
    discussion = create :mentor_discussion, :mentor_finished, mentor: user

    # The mentor reputation token's category is building
    User::ReputationToken::Create.(
      user,
      :mentored,
      discussion:
    )

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::ContributorBadge
  end

  test "does not award contributor token if category is publishing" do
    user = create :user
    solution = create :practice_solution, :published, user: user

    # The published reputation token's category is publishing
    User::ReputationToken::Create.(
      user,
      :published_solution,
      solution:,
      level: :medium
    )

    perform_enqueued_jobs
    refute_includes user.reload.badges.map(&:class), Badges::ContributorBadge
  end

  test "does not award contributor token if category is misc" do
    user = create :user

    # The arbitrary reputation token's category is misc
    User::ReputationToken::Create.(
      user,
      :arbitrary,
      arbitrary_value: 23,
      arbitrary_reason: 'For helping troubleshoot'
    )

    perform_enqueued_jobs
    refute_includes user.reload.badges.map(&:class), Badges::ContributorBadge
  end
end
