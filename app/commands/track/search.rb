class Track
  class Search
    STATUSES = %i[all joined unjoined].freeze

    include Mandate

    def initialize(criteria: nil, tags: nil, status: nil, user: nil)
      @criteria = criteria
      @tags = tags
      @status = status.try(&:to_sym)
      @user = user
    end

    def call
      @tracks = Track.active
      filter_criteria
      filter_tags
      filter_status
      @tracks
    end

    private
    attr_reader :criteria, :tags, :status, :user
    attr_reader :tracks

    def filter_criteria
      return if criteria.blank?

      @tracks = tracks.where(
        "title like ?", "%#{criteria}%"
      )
    end

    # TODO: Decide how to model tags filter
    # and add it here.
    def filter_tags; end

    def filter_status
      return if status.blank?
      raise TrackSearchStatusWithoutUserError unless user
      raise TrackSearchInvalidStatusError unless STATUSES.include?(status.to_sym)
      return if status == :all

      @tracks = if status == :joined
                  tracks.where(id: user.tracks)
                else
                  tracks.where.not(id: user.tracks)
                end
    end
  end
end
