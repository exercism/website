module User::Roles
  def founder? = roles.include?(:founder)
  def admin? = roles.include?(:admin)
  def staff? = roles.include?(:staff)
  def maintainer? = roles.include?(:maintainer)
  # def supermentor? = roles.include?(:supermentor)
  def supermentor? = false
  def roles = super.to_a.map(&:to_sym).to_set
end
