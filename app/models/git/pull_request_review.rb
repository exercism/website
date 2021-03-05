class Git::PullRequestReview < ApplicationRecord
  belongs_to :pull_request,
    inverse_of: :reviews,
    foreign_key: "git_pull_request_id",
    class_name: "Git::PullRequest"
end
