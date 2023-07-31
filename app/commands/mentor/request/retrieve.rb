class Mentor::Request::Retrieve
  include Mandate

  # Use class method rather than constant for
  # easier stubbing during testing
  def self.requests_per_page
    25
  end

  def initialize(mentor:,
                 page: 1,
                 criteria: nil, order: nil,
                 track_slug: nil, exercise_slug: nil,
                 limit_tracks: true, sorted: true, paginated: true)
    @mentor = mentor
    @page = page
    @criteria = criteria
    @order = order
    @track_slug = track_slug
    @exercise_slug = exercise_slug

    @limit_tracks = limit_tracks
    @sorted = sorted
    @paginated = paginated
  end

  def call
    setup!
    filter!
    search!
    sort! if sorted?
    paginate! if paginated?

    @requests
  end

  private
  attr_reader :mentor, :page, :criteria, :order,
    :track_slug, :exercise_slug

  %i[sorted paginated limit_tracks].each do |attr|
    define_method("#{attr}?") { instance_variable_get("@#{attr}") }
  end

  def setup!
    @requests = Mentor::Request.
      pending.
      unlocked_for(mentor)
  end

  def filter!
    # Don't allow a user to request their own solutions
    @requests = @requests.where.not('student_id': mentor.id) if mentor

    # Don't show mentor-blocked or student-blocked solutions
    @requests = @requests.where.not(
      student_id: Mentor::StudentRelationship.
        where(mentor:).
        where('blocked_by_mentor = ? OR blocked_by_student = ?', true, true).
        select(:student_id)
    )

    if exercise_slug.present?
      filter_exercises!
    else
      filter_track!
    end
  end

  def filter_exercises!
    return if track_slug.blank?
    return if exercise_slug.blank?

    exercise_id = Exercise.where(
      slug: exercise_slug,
      track_id: Track.where(slug: track_slug).select(:id)
    ).pick(:id)

    @requests = @requests.where(exercise_id:)
  end

  def filter_track!
    return unless limit_tracks?

    track_ids = track_slug.present? ?
      Track.where(slug: track_slug).select(:id) :
      mentor.track_mentorships.select(:track_id)

    @requests = @requests.where(track_id: track_ids)
  end

  def search!
    return if criteria.blank?

    @requests = @requests.joins(:student).where("users.handle LIKE ?", "%#{criteria}%")
  end

  def sort!
    case order
    when "recent"
      @requests = @requests.order("mentor_requests.id DESC")
    else
      @requests = @requests.order("mentor_requests.id ASC")
    end
  end

  def paginate!
    @requests = @requests.
      page(page).per(self.class.requests_per_page)
  end
end
