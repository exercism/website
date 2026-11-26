class User::RetrieveRoleHolders
  include Mandate

  DEFAULT_PER = 50

  initialize_with role: nil, page: 1, per: DEFAULT_PER

  def call
    users = User.joins(:data).includes(:data).where(user_data: { has_roles: true })
    users = users.where("JSON_CONTAINS(user_data.roles, ?, '$')", role.to_s.to_json) if role.present?
    users.order(:handle).page(page).per(per)
  end
end
