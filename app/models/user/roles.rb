module User::Roles
  def founder? = roles.include?(:founder)
  def admin? = roles.include?(:admin)
  def staff? = roles.include?(:staff) || admin?
  def maintainer? = roles.include?(:maintainer) || admin? || staff?
  def supermentor? = roles.include?(:supermentor) || admin? || staff?
  def mentor? = became_mentor_at.present? || admin? || staff?
  def roles = super.to_a.map(&:to_sym).to_set
end
