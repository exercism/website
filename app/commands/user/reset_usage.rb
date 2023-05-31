class User::ResetUsage
  include Mandate

  initialize_with :user, :group, :metric

  def call
    user.usages[group.to_s] ||= {}
    user.usages[group.to_s][metric] = nil
    user.save!
  end
end
