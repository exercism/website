module V2ETL
  module DataProcessors
    class ProcessSolutions
      include Mandate

      def call
        Solution.where(status: 0).where.not(published_at: nil).update_all(status: :published)
        Solution.where(status: 0).where.not(completed_at: nil).update_all(status: :completed)
        Solution.where(status: 0).where(id: Iteration.select(:solution_id)).update_all(status: :iterated)

        Solution.where(mentoring_status: 0).where(id: Mentor::Discussion.where.not(status: %i[mentor_finished finished]).select(:solution_id)).update_all(mentoring_status: :in_progress)
        Solution.where(mentoring_status: 0).where(id: Mentor::Discussion.where(status: %i[mentor_finished finished]).select(:solution_id)).update_all(mentoring_status: :finished)
        Solution.where(mentoring_status: 0).where(id: Mentor::Request.select(:solution_id)).update_all(mentoring_status: :requested)

        # TODO: Uncomment these
        # connection.remove_column :solutions, :approved_by_id
        # connection.remove_column :solutions, :mentoring_requested_at
      end
    end
  end
end
