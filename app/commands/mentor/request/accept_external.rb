class Mentor::Request::AcceptExternal
  include Mandate

  initialize_with :mentor, :solution

  def call
    Mentor::Request.transaction do
      request = Mentor::Request.create!(
        solution:,
        comment_markdown: "This is a private review session",
        external: true
      )
      request.fulfilled!
      log_metric!(request)
      Mentor::Discussion.create!(
        mentor:,
        request:,
        awaiting_student_since: Time.current,
        external: true
      )
    end
  end

  private
  def log_metric!(request)
    Metric::Queue.(:request_private_mentoring, request.created_at, request:, track:, user:)
  end

  def user = solution.user
  def track = solution.track
end
