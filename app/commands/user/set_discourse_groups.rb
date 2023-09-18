class User::SetDiscourseGroups
  include Mandate

  initialize_with :user

  def call
    set_trust_level!
    set_pm_enabled!
    set_insiders!
  rescue DiscourseApi::NotFoundError
    # If the external user can't be found, then the
    # oauth didn't complete so there's nothing to do.
  end

  private
  def set_trust_level!
    return if user.reputation < MIN_REP_FOR_TRUST_LEVEL

    client.update_trust_level(discourse_user_id, level: 2)
  end

  def set_pm_enabled!
    return if user.reputation < MIN_REP_FOR_PM_ENABLED

    add_to_group!(PM_ENABLED_GROUP_NAME)
  end

  def set_insiders!
    if user.insider?
      add_to_group!(INSIDERS_GROUP_NAME)
    else
      remove_from_group!(INSIDERS_GROUP_NAME)
    end
  end

  def add_to_group!(group_name)
    client.group_add(group_id(group_name), user_id: [discourse_user_id])
  rescue DiscourseApi::UnprocessableEntity
    # If the user was already a member of the group,
    # ignore the error
  end

  def remove_from_group!(group_name)
    client.group_remove(group_id(group_name), user_id: [discourse_user_id])
  rescue DiscourseApi::UnprocessableEntity
    # If the user was not a member of the group,
    # ignore the error
  end

  def group_id(group_name) = client.group(group_name).dig(*%w[group id])

  memoize
  def discourse_user_id = discourse_user_data['id']

  memoize
  def discourse_user_data = client.by_external_id(user.id)

  memoize
  def client = Exercism.discourse_client

  MIN_REP_FOR_TRUST_LEVEL = 20
  MIN_REP_FOR_PM_ENABLED = 1000

  PM_ENABLED_GROUP_NAME = "pm-enabled".freeze
  INSIDERS_GROUP_NAME = "insiders".freeze
end
