class Solution::SyncAllToSearchIndex
  include Mandate

  def call
    Solution.includes(:user, latest_iteration: [submission: :files], exercise: :track).find_each.each_slice(BATCH_SIZE) do |solutions|
      body = solutions.map do |solution|
        {
          index: {
            _index: Solution::OPENSEARCH_INDEX,
            _id: solution.id,
            data: Solution::CreateSearchIndexDocument.(solution)
          }
        }
      end

      Exercism.opensearch_client.bulk(body: body)
    end
  end

  BATCH_SIZE = 1000
  private_constant :BATCH_SIZE
end
