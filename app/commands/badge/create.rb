class Badge
  class Create
    include Mandate

    initialize_with :user, :slug

    def call
      klass = Badge.slug_to_type(slug).constantize

      # Check to see if it exists already before
      # doing any other expensive things
      begin
        return klass.find_by!(user: user)
      rescue ActiveRecord::RecordNotFound; end

      # Build the badge
      badge = klass.new(user: user)

      # Check if the badge should be awarded. 
      # Raise an exception if not
      unless badge.should_award?
        raise BadgeCriteriaNotFulfilledError 
      end

      begin
        badge.save!
        Notification::Create.(user, :acquired_badge, {badge: badge})
        badge

      # Guard against the race condition
      # and return the badge if it's been created
      # in paralel to this command
      rescue ActiveRecord::RecordNotUnique
        klass.find_by!(user: user)
      end
    end
  end
end

