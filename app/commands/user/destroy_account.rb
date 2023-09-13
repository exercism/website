class User::DestroyAccount
  include Mandate

  initialize_with :user

  def call
    User::ResetAccount.(user)
    user.student_relationships.destroy_all
    user.mentor_relationships.destroy_all
    user.subscriptions.destroy_all
    user.payments.destroy_all
    user.destroy
  end
end
