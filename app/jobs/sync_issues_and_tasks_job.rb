# The goal of this job is to re-import the GitHub issues to guard against
# one of the GitHub webhook calls failing, which would result in missing issues
class SyncIssuesAndTasksJob < ApplicationJob
  queue_as :dribble

  def perform
    Github::Issue::SyncRepos.()
    Github::Task::SyncTasks.()
  end
end
