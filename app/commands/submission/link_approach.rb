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

    num_solutions = Submission.where(approach:).select(:solution_id).distinct.count
    approach.update_column(:num_solutions, num_solutions)
  end
end
