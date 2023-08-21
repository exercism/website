require 'test_helper'

class SerializeTaskTest < ActiveSupport::TestCase
  test "serialize track task" do
    freeze_time do
      create :track, slug: 'ruby', title: 'Ruby'
      task = create :github_task, issue_url: 'https://github.com/exercism/ruby/issues/312',
        title: 'Sync anagram', opened_at: 2.days.ago, opened_by_username: 'ErikSchierboom',
        action: :fix, knowledge: :none, area: :representer, size: :massive, type: :docs

      expected = {
        uuid: task.uuid,
        title: 'Sync anagram',
        tags: {
          action: :fix,
          knowledge: :none,
          module: :representer,
          size: :massive,
          type: :docs
        },
        track: {
          slug: 'ruby',
          title: 'Ruby',
          icon_url: 'https://assets.exercism.org/tracks/ruby.svg'
        },
        opened_by_username: 'ErikSchierboom',
        opened_at: 2.days.ago.iso8601,
        is_new: true,
        links: {
          github_url: "https://github.com/exercism/ruby/issues/312"
        }
      }
      assert_equal expected, SerializeTask.(task)
    end
  end

  test "serialize non-track task" do
    freeze_time do
      task = create :github_task, track: nil, issue_url: 'https://github.com/exercism/configlet/issues/888',
        title: 'Improve test speed', opened_at: 10.days.ago, opened_by_username: 'iHiD',
        action: :fix, knowledge: nil, area: :representer, size: nil, type: :docs

      expected = {
        uuid: task.uuid,
        title: 'Improve test speed',
        tags: {
          action: :fix,
          knowledge: nil,
          module: :representer,
          size: nil,
          type: :docs
        },
        track: nil,
        opened_by_username: 'iHiD',
        opened_at: 10.days.ago.iso8601,
        is_new: false,
        links: {
          github_url: "https://github.com/exercism/configlet/issues/888"
        }
      }
      assert_equal expected, SerializeTask.(task)
    end
  end
end
