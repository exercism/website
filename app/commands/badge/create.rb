class Badge
  class Create
    include Mandate

    initialize_with :user, :type

    def call
      klass = "badges/#{type}_badge".camelize.constantize
      klass.create_or_find_by!(user: user).tap do |badge|
        if badge.just_created?
          Notification::Create.(user, :acquired_badge, {badge: badge})
        end
      end
    end
  end
end

