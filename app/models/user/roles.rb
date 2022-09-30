module User::Roles
  def founder? = roles.include?(:founder)
  def admin? = roles.include?(:admin)
  def staff? = roles.include?(:staff)
  def maintainer? = roles.include?(:maintainer)

  def supermentor?
    # TODO: enable once we're ready for supermentors
    # rubocop:disable Style/IfUnlessModifier
    # rubocop:disable Style/NumericLiterals
    if Rails.env.production?
      return [3256, 38366, 56500, 76721, 88486, 91576, 757288].include?(id)
    end
    # rubocop:enable Style/IfUnlessModifier

    # rubocop:enable Style/NumericLiterals

    roles.include?(:supermentor)
  end

  def roles = super.to_a.map(&:to_sym).to_set
  def can_view_approaches? = admin? || staff? || maintainer? || supermentor?
end
