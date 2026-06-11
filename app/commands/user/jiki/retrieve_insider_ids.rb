class User::Jiki::RetrieveInsiderIds
  include Mandate

  ACTIVE_STATUSES = %i[active active_lifetime].freeze

  def call
    User.joins(:data).where(user_data: { insiders_status: ACTIVE_STATUSES }).pluck(:id)
  end
end
