class User::UpdateFlair
  include Mandate

  queue_as :default

  initialize_with :user

  def call = user.update!(flair:)

  private
  memoize
  def flair
    return :founder if user.founder?
    return :staff if user.staff?
    return :lifetime_insider if user.insiders_status_active_lifetime?
    return :insider if user.insiders_status_active?

    nil
  end
end
