class User
  class SpendCredits
    class NotEnoughCreditsError < RuntimeError; end

    include Mandate

    initialize_with :user, :amount

    def call
      ActiveRecord::Base.transaction do
        user.lock!

        raise NotEnoughCreditsError if user.available_credits < amount
        user.update_column(:credits, user.available_credits - amount)
      end
    end
  end
end
