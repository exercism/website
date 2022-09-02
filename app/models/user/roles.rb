module User::Roles
  def founder? = roles.include?(:founder)
  def admin? = roles.include?(:admin)
  def staff? = roles.include?(:staff)
  def maintainer? = roles.include?(:maintainer)

  def supermentor?
    # TODO: enable once we're ready for supermentors
    return false if Rails.env.production?

    roles.include?(:supermentor)
  end

  def roles = super.to_a.map(&:to_sym).to_set
end
