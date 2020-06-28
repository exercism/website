class Badge
  class Create
    include Mandate

    initialize_with :user, :slug

    def call
      # Check to see if it exists already before
      # doing any other expensive things
      badge = klass.find_by(user: user)
      return badge if badge

      # Build the badge
      badge = klass.new(user: user)

      # Check if the badge should be awarded.
      # Raise an exception if not
      raise BadgeCriteriaNotFulfilledError unless badge.should_award?

      begin
        badge.save!
        Notification::Create.(user, :acquired_badge, { badge: badge })
        badge

      # Guard against the race condition
      # and return the badge if it's been created
      # in paralel to this command
      rescue ActiveRecord::RecordNotUnique
        klass.find_by!(user: user)
      end
    end

    memoize
    def klass
      Badge.slug_to_type(slug).constantize
    end
  end
end
