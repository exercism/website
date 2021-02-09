class Notification
  class Retrieve
    include Mandate

    # Use class method rather than constant for
    # easier stubbing during testing
    def self.notifications_per_page
      10
    end

    def initialize(user,
                   page: 1,
                   per_page: self.class.notifications_per_page,
                   sorted: true, paginated: true)
      @user = user
      @page = page
      @per_page = per_page

      @sorted = sorted
      @paginated = paginated
    end

    def call
      setup!
      sort! if sorted?
      paginate! if paginated?

      @notifications
    end

    private
    attr_reader :user, :page, :per_page, :criteria, :order,
      :track_slug, :exercise_slugs

    %i[sorted paginated].each do |attr|
      define_method("#{attr}?") { instance_variable_get("@#{attr}") }
    end

    def setup!
      @notifications = user.notifications.unread
    end

    def sort!
      @notifications = @notifications.order(id: :asc)
    end

    def paginate!
      @notifications = @notifications.
        page(page).per(per_page)
    end
  end
end
