class User::Profile::Create
  include Mandate

  initialize_with :user

  def call
    raise ProfileCriteriaNotFulfilledError unless user.may_create_profile?

    user.create_profile!
  end
end
