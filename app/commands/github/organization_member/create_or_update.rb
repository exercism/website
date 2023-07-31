class Github::OrganizationMember::CreateOrUpdate
  include Mandate

  initialize_with :username, attributes: Mandate::KWARGS

  def call
    ::Github::OrganizationMember.create!(username:)
  rescue ActiveRecord::RecordNotUnique
    ::Github::OrganizationMember.find_by!(username:).tap do |member|
      member.update!(attributes)
    end
  end
end
