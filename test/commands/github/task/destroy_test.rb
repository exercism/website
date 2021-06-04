require "test_helper"

class Github::Task::CreateOrUpdateTest < ActiveSupport::TestCase
  test "destroy task" do
    create :github_task, issue_url: 'https://github.com/exercism/ruby/issues/999'

    Github::Task::Destroy.('https://github.com/exercism/ruby/issues/999')

    assert Github::Task.where(issue_url: 'https://github.com/exercism/ruby/issues/999').none?
  end

  test "destroy task that can't be found" do
    Github::Task::Destroy.('https://github.com/exercism/ruby/issues/999')

    assert Github::Task.where(issue_url: 'https://github.com/exercism/ruby/issues/999').none?
  end
end
