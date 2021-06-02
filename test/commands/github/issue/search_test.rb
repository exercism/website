require "test_helper"

class Github::Issue::SearchTest < ActiveSupport::TestCase
  test "no options returns all unclaimed issues, ordered by newest first" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, opened_at: 4.weeks.ago
    issue_3 = create :github_issue, :random, opened_at: 1.week.ago
    issue_4 = create :github_issue, :random, opened_at: 8.weeks.ago

    # Claim an issue
    create :github_issue_label, issue: issue_2, label: 'x:status/claimed'
    create :github_issue_label, issue: issue_4, label: 'x:status/claimed'

    assert_equal [issue_3, issue_1], Github::Issue::Search.()
  end

  test "handles empty inputs" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, opened_at: 1.week.ago

    expected = [issue_2, issue_1]
    assert_equal expected,
      Github::Issue::Search.(action: nil, knowledge: nil, module_: nil, size: nil, type: nil, repo: nil, order: nil,
                             page: nil)
    assert_equal expected,
      Github::Issue::Search.(action: '', knowledge: '', module_: '', size: '', type: '', repo: '', order: '', page: '')
  end

  test "paginates" do
    25.times { create :github_issue, :random }

    first_page = Github::Issue::Search.()
    assert_equal 20, first_page.limit_value # Sanity

    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Github::Issue::Search.(page: 2)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count
  end

  test "filters action correctly" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, opened_at: 4.weeks.ago
    issue_3 = create :github_issue, :random, opened_at: 1.week.ago

    create :github_issue_label, issue: issue_2, label: 'x:action/fix'

    # Add labels to other PRs to ensure they are not counted
    create :github_issue_label, issue: issue_1, label: 'x:action/improve'
    create :github_issue_label, issue: issue_3, label: 'x:action/sync'

    assert_equal [issue_2], Github::Issue::Search.(action: :fix)
  end

  test "filters knowledge correctly" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, opened_at: 4.weeks.ago
    issue_3 = create :github_issue, :random, opened_at: 1.week.ago

    create :github_issue_label, issue: issue_2, label: 'x:knowledge/elementary'

    # Add labels to other PRs to ensure they are not counted
    create :github_issue_label, issue: issue_1, label: 'x:knowledge/none'
    create :github_issue_label, issue: issue_3, label: 'x:knowledge/intermediate'

    assert_equal [issue_2], Github::Issue::Search.(knowledge: :elementary)
  end

  test "filters module correctly" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, opened_at: 4.weeks.ago
    issue_3 = create :github_issue, :random, opened_at: 1.week.ago

    create :github_issue_label, issue: issue_2, label: 'x:module/test-runner'

    # Add labels to other PRs to ensure they are not counted
    create :github_issue_label, issue: issue_1, label: 'x:module/concept-exercise'
    create :github_issue_label, issue: issue_3, label: 'x:module/analyzer'

    assert_equal [issue_2], Github::Issue::Search.(module_: :test_runner)
  end

  test "filters size correctly" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, opened_at: 4.weeks.ago
    issue_3 = create :github_issue, :random, opened_at: 1.week.ago

    create :github_issue_label, issue: issue_2, label: 'x:size/m'

    # Add labels to other PRs to ensure they are not counted
    create :github_issue_label, issue: issue_1, label: 'x:size/xs'
    create :github_issue_label, issue: issue_3, label: 'x:size/l'

    assert_equal [issue_2], Github::Issue::Search.(size: :m)
  end

  test "filters type correctly" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, opened_at: 4.weeks.ago
    issue_3 = create :github_issue, :random, opened_at: 1.week.ago

    create :github_issue_label, issue: issue_2, label: 'x:type/coding'

    # Add labels to other PRs to ensure they are not counted
    create :github_issue_label, issue: issue_1, label: 'x:type/ci'
    create :github_issue_label, issue: issue_3, label: 'x:type/docker'

    assert_equal [issue_2], Github::Issue::Search.(type: :coding)
  end

  test "filters repo correctly" do
    issue_1 = create :github_issue, :random, repo: 'exercism/fsharp', opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, repo: 'exercism/fsharp', opened_at: 1.week.ago

    # Add issues for other repos to ensure they are not counted
    create :github_issue, :random, repo: 'exercism/csharp'
    create :github_issue, :random, repo: 'exercism/ruby'

    assert_equal [issue_2, issue_1], Github::Issue::Search.(repo: 'exercism/fsharp')
  end

  test "combine multiple filters correctly" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago
    issue_2 = create :github_issue, :random, opened_at: 4.weeks.ago
    issue_3 = create :github_issue, :random, opened_at: 1.week.ago
    issue_4 = create :github_issue, :random, opened_at: 3.weeks.ago
    issue_5 = create :github_issue, :random, opened_at: 6.weeks.ago

    create :github_issue_label, issue: issue_1, label: 'x:knowledge/intermediate'
    create :github_issue_label, issue: issue_1, label: 'x:size/s'
    create :github_issue_label, issue: issue_5, label: 'x:knowledge/intermediate'
    create :github_issue_label, issue: issue_5, label: 'x:size/s'

    # Add labels to other PRs to ensure they are not counted
    create :github_issue_label, issue: issue_2, label: 'x:knowledge/intermediate'
    create :github_issue_label, issue: issue_2, label: 'x:size/xl'
    create :github_issue_label, issue: issue_3, label: 'x:size/s'
    create :github_issue_label, issue: issue_4, label: 'x:knowledge/intermediate'

    assert_equal [issue_1, issue_5], Github::Issue::Search.(knowledge: :intermediate, size: :s)
  end

  test "orders correctly" do
    issue_1 = create :github_issue, :random, opened_at: 2.weeks.ago, repo: 'exercism/fsharp'
    issue_2 = create :github_issue, :random, opened_at: 4.weeks.ago, repo: 'exercism/csharp'
    issue_3 = create :github_issue, :random, opened_at: 1.week.ago, repo: 'exercism/d'

    assert_equal [issue_3, issue_1, issue_2], Github::Issue::Search.(order: :newest)
    assert_equal [issue_2, issue_1, issue_3], Github::Issue::Search.(order: :oldest)
    assert_equal [issue_2, issue_3, issue_1], Github::Issue::Search.(order: :track)
  end
end
