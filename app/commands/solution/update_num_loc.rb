class Solution::UpdateNumLoc
  include Mandate

  initialize_with :solution

  def call
    if iteration && iteration.num_loc.nil?
      Solution::UpdateNumLoc.defer(solution,
        prereq_jobs: [
          Iteration::CountLinesOfCode.defer(iteration)
        ])
      return
    end

    return if num_loc == solution.num_loc

    solution.update!(num_loc:)
    resync_representation_to_search_index!
  end

  private
  def num_loc
    iteration&.num_loc.to_i
  end

  memoize
  def iteration
    solution.latest_published_iteration || solution.latest_iteration
  end

  def resync_representation_to_search_index!
    Exercise::Representation.where(oldest_solution: solution).each do |representation|
      Exercise::Representation::SyncToSearchIndex.defer(representation)
    end
  end
end
