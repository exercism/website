require "test_helper"

class Github::Task::SearchTest < ActiveSupport::TestCase
  test "no options returns all tasks, ordered by newest first" do
    task_1 = create :github_task, :random, opened_at: 2.weeks.ago
    task_2 = create :github_task, :random, opened_at: 4.weeks.ago
    task_3 = create :github_task, :random, opened_at: 1.week.ago

    assert_equal [task_3, task_1, task_2], Github::Task::Search.()
  end

  test "handles empty inputs" do
    task_1 = create :github_task, :random, opened_at: 2.weeks.ago
    task_2 = create :github_task, :random, opened_at: 1.week.ago

    expected = [task_2, task_1]
    assert_equal expected,
      Github::Task::Search.(actions: nil, knowledge: nil, areas: nil, sizes: nil, types: nil, repo_url: nil, order: nil,
        track_id: nil, page: nil)
    assert_equal expected,
      Github::Task::Search.(actions: '', knowledge: '', areas: '', sizes: '', types: '', repo_url: '', order: '',
        track_id: nil, page: '')
  end

  test "paginates" do
    25.times { create :github_task, :random }

    first_page = Github::Task::Search.()
    assert_equal 20, first_page.limit_value # Sanity

    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Github::Task::Search.(page: 2)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count
  end

  test "filters track correctly" do
    track_1 = create :track, slug: 'fsharp'
    track_2 = create :track, slug: 'ruby'

    task_1 = create :github_task, :random, opened_at: 4.weeks.ago, track: track_1
    task_2 = create :github_task, :random, opened_at: 1.week.ago, track: track_1

    # Add non-matching tasks to ensure they are not counted
    create :github_task, :random, track: track_2
    create :github_task, :random, track: track_2

    assert_equal [task_2, task_1], Github::Task::Search.(track_id: track_1.id)
  end

  test "filters actions correctly" do
    task_1 = create :github_task, :random, opened_at: 2.weeks.ago, action: :fix
    task_2 = create :github_task, :random, opened_at: 4.weeks.ago, action: :fix

    # Add non-matching tasks to ensure they are not counted
    create :github_task, :random, action: :improve
    create :github_task, :random, action: nil

    assert_equal [task_1, task_2], Github::Task::Search.(actions: [:fix])
  end

  test "filters knowledge correctly" do
    task_1 = create :github_task, :random, opened_at: 2.weeks.ago, knowledge: :elementary
    task_2 = create :github_task, :random, opened_at: 4.weeks.ago, knowledge: :elementary
    task_3 = create :github_task, :random, opened_at: 1.week.ago, knowledge: :elementary

    # Add non-matching tasks to ensure they are not counted
    create :github_task, :random, knowledge: :advanced
    create :github_task, :random, knowledge: nil

    assert_equal [task_3, task_1, task_2], Github::Task::Search.(knowledge: [:elementary])
  end

  test "filters areas correctly" do
    task_1 = create :github_task, :random, opened_at: 2.weeks.ago, area: :analyzer

    # Add non-matching tasks to ensure they are not counted
    create :github_task, :random, area: :representer
    create :github_task, :random, area: nil

    assert_equal [task_1], Github::Task::Search.(areas: [:analyzer])
  end

  test "filters sizes correctly" do
    task_1 = create :github_task, :random, opened_at: 2.weeks.ago, size: :medium
    task_2 = create :github_task, :random, opened_at: 4.weeks.ago, size: :medium

    # Add non-matching tasks to ensure they are not counted
    create :github_task, :random, size: :large
    create :github_task, :random, size: nil

    assert_equal [task_1, task_2], Github::Task::Search.(sizes: [:medium])
  end

  test "filters types correctly" do
    task_1 = create :github_task, :random, opened_at: 2.weeks.ago, type: :coding

    # Add non-matching tasks to ensure they are not counted
    create :github_task, :random, type: :docs
    create :github_task, :random, type: nil

    assert_equal [task_1], Github::Task::Search.(types: [:coding])
  end

  test "filters repo correctly" do
    task_1 = create :github_task, :random, repo: 'exercism/fsharp', opened_at: 2.weeks.ago
    task_2 = create :github_task, :random, repo: 'exercism/fsharp', opened_at: 1.week.ago

    # Add tasks for other repos to ensure they are not counted
    create :github_task, :random, repo: 'exercism/csharp'
    create :github_task, :random, repo: 'exercism/ruby'

    assert_equal [task_2, task_1], Github::Task::Search.(repo_url: 'exercism/fsharp')
  end

  test "combine multiple filters correctly" do
    task_1 = create :github_task, :random, opened_at: 1.week.ago, type: :coding, size: :small
    task_2 = create :github_task, :random, opened_at: 2.weeks.ago, type: :coding, size: :small

    # Add non-matching tasks to ensure they are not counted
    create :github_task, :random, type: :docs, size: :small
    create :github_task, :random, type: :coding, size: :medium
    create :github_task, :random, type: :coding, size: nil
    create :github_task, :random, type: nil, size: :small
    create :github_task, :random, type: nil, size: nil

    assert_equal [task_1, task_2], Github::Task::Search.(types: [:coding], sizes: [:small])
  end

  test "combine multiple filters with multiple values correctly" do
    task_1 = create :github_task, :random, opened_at: 1.week.ago, type: :coding, size: :small
    task_2 = create :github_task, :random, opened_at: 2.weeks.ago, type: :coding, size: :small
    task_3 = create :github_task, :random, opened_at: 3.weeks.ago, type: :docs, size: :small
    task_4 = create :github_task, :random, opened_at: 8.weeks.ago, type: :docs, size: :medium
    task_5 = create :github_task, :random, opened_at: 6.weeks.ago, type: :coding, size: :medium

    # Add non-matching tasks to ensure they are not counted
    create :github_task, :random, type: :coding, size: nil
    create :github_task, :random, type: :coding, size: :large
    create :github_task, :random, type: nil, size: :small
    create :github_task, :random, type: nil, size: nil
    create :github_task, :random, type: :docker, size: :small

    expected = [task_1, task_2, task_3, task_5, task_4]
    assert_equal expected, Github::Task::Search.(types: %i[coding docs], sizes: %i[small medium])
  end

  test "orders correctly" do
    task_1 = create :github_task, :random, opened_at: 2.weeks.ago, track: (create :track, slug: 'fsharp')
    task_2 = create :github_task, :random, opened_at: 4.weeks.ago, track: (create :track, slug: 'csharp')
    task_3 = create :github_task, :random, opened_at: 1.week.ago, track: (create :track, slug: 'd')

    assert_equal [task_3, task_1, task_2], Github::Task::Search.(order: "newest")
    assert_equal [task_2, task_1, task_3], Github::Task::Search.(order: "oldest")
    assert_equal [task_2, task_3, task_1], Github::Task::Search.(order: "track")
  end

  test "returns relationship unless paginated" do
    create :github_task, :random, opened_at: 2.weeks.ago, track: (create :track, slug: 'fsharp')
    create :github_task, :random, opened_at: 4.weeks.ago, track: (create :track, slug: 'csharp')

    tasks = Github::Task::Search.(paginated: false)
    assert tasks.is_a?(ActiveRecord::Relation)
    refute_respond_to tasks, :current_page
  end
end
