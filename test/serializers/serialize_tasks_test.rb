require 'test_helper'

class SerializeTasksTest < ActiveSupport::TestCase
  test "serializes tasks" do
    freeze_time do
      task_1 = create :github_task, issue_url: 'https://github.com/exercism/fsharp/issues/99',
                                    title: 'Fix generator', opened_at: 3.weeks.ago, opened_by_username: 'ErikSchierboom'
      task_2 = create :github_task, issue_url: 'https://github.com/exercism/ruby/issues/312',
                                    title: 'Sync anagram', opened_at: 2.days.ago, opened_by_username: 'iHiD'
      tasks = [task_1, task_2]

      expected = [
        {
          title: "Fix generator",
          track: {
            slug: "ruby",
            title: "Ruby",
            icon_url: "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/tracks/ruby.svg"
          },
          opened_by_username: "ErikSchierboom",
          opened_at: 3.weeks.ago.iso8601,
          is_new: false,
          links: {
            github_url: "https://github.com/exercism/fsharp/issues/99"
          }
        },
        {
          title: "Sync anagram",
          track: {
            slug: "ruby",
            title: "Ruby",
            icon_url: "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/tracks/ruby.svg"
          },
          opened_by_username: "iHiD",
          opened_at: 2.days.ago.iso8601,
          is_new: true,
          links: {
            github_url: "https://github.com/exercism/ruby/issues/312"
          }
        }
      ]
      assert_equal expected, SerializeTasks.(tasks)
    end
  end
end
