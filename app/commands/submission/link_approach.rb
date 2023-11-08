class Submission::LinkApproach
  include Mandate

  initialize_with :submission, :approach

  def call
    old_approach = submission.approach

    return if approach == old_approach

    submission.update!(approach:)

    update_approach(approach)
    update_approach(old_approach)
  end

  private
  def update_approach(approach)
    return unless approach

    num_submissions = Submission.where(approach:).count
    approach.update!(num_submissions:)
  end
end
