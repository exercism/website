class Solution::SyncAllToSearchIndex
  include Mandate

  def call
    Solution.includes(
      :user,
      :track,
      published_iteration: %i[files submission],
      latest_iteration: %i[files submission],
      exercise: :track
    ).find_each.each_slice(BATCH_SIZE) do |solutions|
      body = solutions.map do |solution|
        {
          index: {
            _index: Solution::OPENSEARCH_INDEX,
            _id: solution.id,
            _type: 'solution',
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
