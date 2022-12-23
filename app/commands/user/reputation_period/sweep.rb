class User::ReputationPeriod::Sweep
  include Mandate

  def call
    User::ReputationPeriod.dirty.find_each do |period|
      User::ReputationPeriod::UpdateReputation.(period)
    end
  end
end
