module Github
  class OrganizationMember
    class CreateOrUpdate
      include Mandate

      initialize_with :username, :attributes

      def call
        ::Github::OrganizationMember.create!(username: username)
      rescue ActiveRecord::RecordNotUnique
        ::Github::OrganizationMember.find_by!(username: username).tap do |member|
          member.update!(attributes)
        end
      end
    end
  end
end
