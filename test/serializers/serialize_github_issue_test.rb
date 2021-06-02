require 'test_helper'

class SerializeGithubIssueTest < ActiveSupport::TestCase
  test "serialize track issue" do
    create :track, slug: 'ruby', title: 'Ruby'
    issue = create :github_issue, number: 312, title: 'Sync anagram', repo: 'exercism/ruby', opened_at: 2.days.ago

    expected = {
      title: 'Sync anagram',
      track: {
        slug: 'ruby',
        title: 'Ruby',
        icon_url: 'https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/tracks/ruby.svg'
      },
      is_new: true,
      links: {
        github_url: "https://github.com/exercism/ruby/issues/312"
      }
    }
    assert_equal expected, SerializeGithubIssue.(issue)
  end

  test "serialize non-track issue" do
    issue = create :github_issue, number: 888, title: 'Improve test speed', repo: 'exercism/configlet',
                                  opened_at: 10.days.ago

    expected = {
      title: 'Improve test speed',
      track: nil,
      is_new: false,
      links: {
        github_url: "https://github.com/exercism/configlet/issues/888"
      }
    }
    assert_equal expected, SerializeGithubIssue.(issue)
  end
end
