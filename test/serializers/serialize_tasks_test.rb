require 'test_helper'

class SerializeTasksTest < ActiveSupport::TestCase
  test "serializes tasks" do
    freeze_time do
      task_1 = create :github_task, issue_url: 'https://github.com/exercism/fsharp/issues/99',
        title: 'Fix generator', opened_at: 3.weeks.ago, opened_by_username: 'ErikSchierboom',
        action: :fix, knowledge: nil, area: :representer, size: nil, type: :docs
      task_2 = create :github_task, issue_url: 'https://github.com/exercism/ruby/issues/312',
        title: 'Sync anagram', opened_at: 2.days.ago, opened_by_username: 'iHiD',
        action: :improve, knowledge: :none, area: :analyzer, size: :massive, type: :ci
      tasks = Github::Task.where(id: [task_1, task_2])

      expected = [
        SerializeTask.(task_1),
        SerializeTask.(task_2)
      ]
      assert_equal expected, SerializeTasks.(tasks)
    end
  end
end
