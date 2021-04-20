module User::Roles
  def founder?
    roles.include?(:founder)
  end

  def admin?
    roles.include?(:admin)
  end

  def staff?
    roles.include?(:staff)
  end

  def maintainer?
    roles.include?(:maintainer)
  end

  def roles
    super.to_a.map(&:to_sym)
  end
end
