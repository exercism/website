require 'test_helper'

class SerializeTasksTest < ActiveSupport::TestCase
  test "serializes tasks" do
    freeze_time do
      create :user, github_username: 'ErikSchierboom'
      create :user, github_username: 'iHiD'
      ruby = create :track, slug: "ruby"
      fsharp = create :track, slug: "fsharp"

      task_1 = create :github_task, issue_url: 'https://github.com/exercism/fsharp/issues/99',
        title: 'Fix generator', opened_at: 3.weeks.ago, opened_by_username: 'ErikSchierboom',
        action: :fix, knowledge: nil, area: :representer, size: nil, type: :docs, track: ruby
      task_2 = create :github_task, issue_url: 'https://github.com/exercism/ruby/issues/312',
        title: 'Sync anagram', opened_at: 2.days.ago, opened_by_username: 'iHiD',
        action: :improve, knowledge: :none, area: :analyzer, size: :massive, type: :ci, track: fsharp

      expected = [
        SerializeTask.(task_1),
        SerializeTask.(task_2)
      ]

      Bullet.profile do
        assert_equal expected, SerializeTasks.(Github::Task.all)
      end
    end
  end
end
