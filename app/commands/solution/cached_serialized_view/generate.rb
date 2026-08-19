# Builds the serialized solution-view payload for the community solution
# page. This is the publicly-visible (non-author) variant: only published
# iterations, and no author-only links. Author-only data must be added
# outside this payload as it gets cached (see Retrieve).
class Solution::CachedSerializedView::Generate
  include Mandate

  initialize_with :solution

  def call
    {
      iterations: SerializeIterations.(solution.published_iterations),
      language: solution.track.highlightjs_language,
      indent_size: solution.track.indent_size,
      out_of_date: solution.out_of_date?,
      published_iteration_idx: solution.published_iteration.try(:idx),
      published_iteration_idxs: solution.published_iterations.pluck(:idx)
    }
  end
end
