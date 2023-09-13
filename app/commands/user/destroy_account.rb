class User::DestroyAccount
  include Mandate

  initialize_with :user

  def call
    User::ResetAccount.(user)
    user.student_relationships.destroy_all
    user.mentor_relationships.destroy_all
    user.subscriptions.update_all(user_id: User::GHOST_USER_ID)
    user.payments.update_all(user_id: User::GHOST_USER_ID)
    user.destroy
  end
end
