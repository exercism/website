class User::BecomeTrainer
  include Mandate

  initialize_with :user

  def call
    return if user.trainer?

    raise TrainerCriteriaNotFulfilledError unless user.eligible_for_trainer?

    user.update!(trainer: true)
  end
end
