class AddApproachSolutionIndexToSubmissions < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    # Submission::LinkApproach recounts an approach's distinct solutions on
    # every link. index_submissions_on_approach_id covers (approach_id, id),
    # so COUNT(DISTINCT solution_id) needed a clustered-index lookup per row:
    # 14,774 random reads for the largest approach, 15.7s on a cold buffer
    # pool. Adding solution_id makes it an index-only scan.
    #
    # Already created manually on production, hence if_not_exists.
    add_index :submissions, %i[approach_id solution_id],
      name: "index_submissions_on_approach_id_and_solution_id",
      if_not_exists: true
  end
end
