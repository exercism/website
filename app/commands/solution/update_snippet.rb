class Solution
  class UpdateSnippet
    include Mandate

    initialize_with :solution

    def call = solution.update(snippet: snippet)

    private
    def snippet = snippet_iteration&.snippet
    def snippet_iteration = solution.latest_published_iteration || solution.latest_iteration
  end
end
