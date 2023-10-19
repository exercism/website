class Exercise::Representation::CreateOrUpdate
  include Mandate

  initialize_with :submission, :ast, :ast_digest, :mapping, :representer_version, :exercise_version, :last_submitted_at, :git_sha

  def call
    # First cache the old representation
    @old_representation = Exercise::Representation.where(source_submission: submission).last

    @representation = Exercise::Representation.find_create_or_find_by!(
      exercise:, ast_digest:, representer_version:, exercise_version:
    ) do |rep|
      rep.source_submission = submission
      rep.ast = ast
      rep.mapping = mapping
      rep.last_submitted_at = last_submitted_at
    end

    # Do this straight away before anything else
    representation_is_new = representation.id_previously_changed?

    Exercise::Representation::Recache.(representation, last_submitted_at:)

    # Now copy the old feedback and trigger runs if we've created a new representation that's different from the old one
    if representation_is_new && old_representation && representation != old_representation
      update_feedback!
      trigger_reruns!
    end

    representation
  end

  private
  attr_reader :representation, :old_representation

  delegate :exercise, to: :submission

  def update_feedback!
    return unless old_representation&.has_feedback?

    # Don't overriden new feedback if it's been given (I don't think
    # this can ever occur but it's just a guard in case of some weirdness)
    return if representation.has_feedback?

    # If either of the two version keys have changed then we only want to
    # save this as draft feedback, not actual feedback as we can't guarantee
    # it's definitely appropriate now.
    return add_draft_feedback! if representation.exercise_version != old_representation.exercise_version
    return add_draft_feedback! if representation.representer_version != old_representation.representer_version

    representation.update!(
      feedback_author: old_representation.feedback_author,
      feedback_markdown: old_representation.feedback_markdown,
      feedback_type: old_representation.feedback_type
    )
  end

  def add_draft_feedback!
    representation.update!(
      draft_feedback_markdown: old_representation.feedback_markdown,
      draft_feedback_type: old_representation.feedback_type
    )
  end

  def trigger_reruns!
    Exercise::Representation::TriggerReruns.defer(old_representation, git_sha)
  end
end
