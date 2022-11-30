class User::SetDiscourseGroups
  include Mandate

  initialize_with :user

  def call
    set_trust_level!
    set_pm_enabled!
  rescue DiscourseApi::NotFoundError
    # If the external user can't be found, then the
    # oauth didn't complete so there's nothing to do.
  end

  private
  def set_trust_level!
    return unless user.reputation >= MIN_REP_FOR_TRUST_LEVEL

    client.update_trust_level(discourse_user_id, level: 2)
  end

  def set_pm_enabled!
    return unless user.reputation >= MIN_REP_FOR_PM_ENABLED

    group_id = client.group("pm-enabled").dig(*%w[group id])
    client.group_add(group_id, user_id: [discourse_user_id])
  end

  memoize
  def discourse_user_id = discourse_user_data['id']

  memoize
  def discourse_user_data = client.by_external_id(user.id)

  memoize
  def client = Exercism.discourse_client

  MIN_REP_FOR_TRUST_LEVEL = 20
  MIN_REP_FOR_PM_ENABLED = 1000
end
