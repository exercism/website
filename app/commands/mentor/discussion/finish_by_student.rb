class Mentor::Discussion::FinishByStudent
  include Mandate

  def initialize(discussion, rating,
                 requeue: false,
                 report: false,
                 block: false,
                 report_reason: nil,
                 report_message: nil,
                 testimonial: nil)

    @discussion = discussion
    @rating = rating
    @should_requeue = requeue
    @should_report = report
    @should_block = rating == 1 || block
    @report_reason = report_reason
    @report_message = report_message
    @testimonial = testimonial
  end

  def call
    discussion.transaction do
      update!
    end

    requeue!
    report!
    block!
    create_testimonial!
    Mentor::Discussion::ProcessFinished.(discussion)
    notify!
  end

  private
  def update!
    cols = {
      status: :finished,
      awaiting_mentor_since: nil,
      awaiting_student_since: nil,
      rating: rating.to_i
    }
    unless discussion.finished_at
      cols[:finished_at] = Time.current
      cols[:finished_by] = :student
    end
    discussion.update!(cols)
  end

  def requeue!
    return unless should_requeue

    comment = @discussion.request&.comment_markdown || "[No comment provided]"
    Mentor::Request::Create.(@discussion.solution, comment)
  end

  def report!
    return unless should_report

    msg = report_message + "\n\nReason: #{report_reason}"

    ProblemReport.create!(
      user: discussion.student,
      about: discussion,
      content_markdown: msg,
      type: report_reason == "coc" ? :coc : :mentoring
    )
  end

  def block!
    return unless should_block

    Mentor::StudentRelationship.create_or_find_by!(
      mentor: discussion.mentor,
      student: discussion.student
    ).update!(blocked_by_student: true)
  end

  def create_testimonial!
    return if testimonial.blank?

    Mentor::Testimonial::Create.(discussion, testimonial)
  end

  delegate :track, to: :discussion
  delegate :student, to: :discussion

  def notify!
    User::Notification::Create.(
      discussion.mentor,
      :student_finished_discussion,
      discussion:
    )
  end

  attr_reader :discussion, :rating,
    :should_requeue,
    :should_report, :report_reason, :report_message,
    :should_block,
    :testimonial
end
