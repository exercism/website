class Git::PullRequestReview < ApplicationRecord
  belongs_to :pull_request
end
