class Solution::InvalidateCloudfrontItem
  include Mandate

  initialize_with :solution

  def call
    Infrastructure::InvalidateCloudfrontItems.defer(:website, urls)
  end

  private
  def urls
    [Exercism::Routes.published_solution_path(solution, format: :jpg)]
  end
end
