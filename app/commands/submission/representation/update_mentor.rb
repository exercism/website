class Submission::Representation::UpdateMentor
  include Mandate

  initialize_with :submission

  queue_as :solution_processing

  def call
    return unless iteration
    return unless submission_representation
    return unless first_mentor_comment

    submission_representation.update(mentored_by_id: first_mentor_comment.user_id)
  end

  delegate :solution, :iteration, :submission_representation, to: :submission

  private
  memoize
  def first_mentor_comment
    iteration.mentor_discussion_posts.
      where.not(user_id: [student_id, User::GHOST_USER_ID]).
      first
  end

  def student_id = solution.user_id
end
