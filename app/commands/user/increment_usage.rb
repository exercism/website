class User::IncrementUsage
  include Mandate

  initialize_with :user, :group, :metric

  def call
    user.usages[group.to_s] ||= {}
    user.usages[group.to_s][metric] ||= 0
    user.usages[group.to_s][metric] += 1
    user.save!
  end
end
