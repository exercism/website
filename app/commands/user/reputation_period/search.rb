class User::ReputationPeriod
  class Search
    include Mandate

    # Use class method rather than constant for
    # easier stubbing during testing
    def self.requests_per_page
      20
    end

    def initialize(period: nil, category: nil, track_id: 0, user_handle: nil, page: 1)
      @period = period
      @category = category

      @track_id = track_id
      @user_handle = user_handle

      @page = page
    end

    def call
      @rows = User::ReputationPeriod.where.not(reputation: 0)

      filter_period!
      filter_category!
      filter_about!
      filter_user_handle!

      results = @rows.
        order(reputation: :desc, id: :asc).
        select(:user_id).
        page(page).
        per(self.class.requests_per_page).
        without_count

      # TODO: (Optional) Cache this with the expiry key as the id of the last added reputation token
      # and the other keys as the composite parts of the query
      # Unless we specify a user_handle, in which case don't bother
      total_count = @rows.count

      user_ids = results.map(&:user_id)
      users = User.where(id: user_ids).
        order(Arel.sql("FIND_IN_SET(id, '#{user_ids.join(',')}')")).
        includes(:profile).
        with_attached_avatar.
        to_a

      Kaminari.paginate_array(users, total_count:).
        page(page).per(self.class.requests_per_page)
    end

    # This uses a little Rails magic to check the period
    # is valid and if not, default to 0 (the general one).
    # It breaks without the to_s for nil as nil is converted to NULL
    def filter_period!
      @rows = @rows.where(period: User::ReputationPeriod.periods.key?(period) ? period : :forever)
    end

    # This uses a little Rails magic to check the category
    # is valid and if not, default to 0 (the general one).
    # It breaks without the to_s for nil as nil is converted to NULL
    def filter_category!
      @rows = @rows.where(category: User::ReputationPeriod.categories.key?(category) ? category : :any)
    end

    # We set track_ids to be 0 rather than null.
    # This is because mysql can't have unique indexes that contain NULL values.
    # It's not great as it remove our ability to have a foreign key but it's
    # the only real option and it doesn't hugely matter as it's not true relational
    # data but really a complex cache.
    def filter_about!
      if track_id.to_i.positive?
        @rows = @rows.where(about: :track, track_id:)
      else
        @rows = @rows.where(about: :everything)
      end
    end

    def filter_user_handle!
      return if user_handle.blank?

      @rows = @rows.where('user_handle LIKE ?', "#{user_handle}%")
    end

    private
    attr_reader :period, :category, :track_id, :user_handle, :page
  end
end
