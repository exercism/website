class Github::PullRequestReview < ApplicationRecord
  belongs_to :pull_request,
    inverse_of: :reviews,
    foreign_key: "github_pull_request_id",
    class_name: "Github::PullRequest"
end
