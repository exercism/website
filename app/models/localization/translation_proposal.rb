class MutliLingual
  belongs_to :proposer, class_name: 'User'
  belongs_to :reviewer, class_name: 'User'

  enum :status, {
    pending: 0,
    accepted: 1,
    rejected: 2
  }
end
