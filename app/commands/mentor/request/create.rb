class Mentor::Request::Create
  include Mandate

  initialize_with :solution, :comment_markdown

  def call
    guard!

    create_request!
  rescue AlreadyRequestedError => e
    e.request
  end

  private
  def create_request!
    request = Mentor::Request.new(
      solution:,
      comment_markdown:
    )

    ActiveRecord::Base.transaction do
      # By locking the solution before checking the amount of mentorships
      # we should avoid duplicates without having to lock the whole requests table
      solution.lock!

      # Check there's not an existing request. I'd like a unique index
      # but that would involve schema change as we allow multiple fulfilled records.
      existing_request = solution.mentor_requests.pending.first
      raise AlreadyRequestedError, existing_request if existing_request

      request.save!
    end

    log_metric!(request)
    request
  end

  def guard!
    raise NoMentoringSlotsAvailableError unless solution.user_track.has_available_mentoring_slot?
  end

  def log_metric!(request)
    Metric::Queue.(:request_mentoring, request.created_at, request:, track:, user:)
  end

  def user = solution.user
  def track = solution.track

  class AlreadyRequestedError < RuntimeError
    attr_reader :request

    def initialize(request)
      super()

      @request = request
    end
  end
end
