module User::Roles
  def founder? = roles.include?(:founder)
  def admin? = roles.include?(:admin)
  def staff? = roles.include?(:staff)
  def maintainer? = roles.include?(:maintainer)

  def supermentor?
    # TODO: enable once we're ready for supermentors
    return [38_366, 56_500, 76_721, 88_486, 91_576, 757_288].include?(id) if Rails.env.production?

    roles.include?(:supermentor)
  end

  def roles = super.to_a.map(&:to_sym).to_set
end
