class User::ReputationPeriod
  class Search
    include Mandate

    # Use class method rather than constant for
    # easier stubbing during testing
    def self.requests_per_page
      10
    end

    def initialize(period: :forever, category: :any, track_id: nil, user_handle: nil, page: 1)
      @period = period.to_sym
      @category = category.to_sym

      @track_id = track_id
      @user_handle = user_handle

      @page = page
    end

    def call
      @rows = User::ReputationPeriod.
        where(period: period).
        where(category: category)

      filter_about!
      filter_user_handle!

      results = @rows.order(reputation: :desc).
        select(:user_id).
        page(page).
        per(self.class.requests_per_page).
        without_count

      # TODO: Cache this with the expiry key as the id of the last added reputation token
      # and the other keys as the composite parts of the query
      # Unless we specify a user_handle, in which case don't bother
      total_count = @rows.count

      user_ids = results.map(&:user_id)
      users = User.where(id: user_ids).
        order(Arel.sql("FIND_IN_SET(id, '#{user_ids.join(',')}')")).to_a

      Kaminari.paginate_array(users, total_count: total_count).
        page(page).per(self.class.requests_per_page)
    end

    def filter_about!
      if track_id.present?
        @rows = @rows.where(about: :track, track_id: track_id)
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
