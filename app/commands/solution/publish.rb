class Solution
  class Publish
    include Mandate

    initialize_with :solution, :iteration_idxs

    def call
      ActiveRecord::Base.transaction do
        solution.update(published_at: Time.current)
        iterations.update(published: true)
      end
    end

    def iterations
      is = (solution.iterations.where(idx: iteration_idxs) if iteration_idxs.present?)
      is.presence || solution.iterations.last
    end
  end
end
