class Metric < ApplicationRecord
  enum action: {
    submit_solution: 0,
    complete_solution: 1,
    publish_solution: 2,
    request_mentoring: 3,
    finish_mentoring: 4,
    open_issue: 5,
    open_pull_request: 6,
    merge_pull_request: 7
  }

  belongs_to :track
  belongs_to :user

  def action
    super.to_sym
  end
end
