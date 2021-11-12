class Solution::SyncAllToSearchIndex
  include Mandate

  def initialize(since: nil)
    @since = since
  end

  def call
    solutions = Solution.includes(
      :user,
      :track,
      published_iteration: %i[files submission],
      latest_iteration: %i[files submission],
      exercise: :track
    )
    solutions = solutions.where("updated_at > ?", since) if since.present?

    solutions.find_in_batches(batch_size: BATCH_SIZE) do |batch|
      body = batch.map do |solution|
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

  private
  attr_reader :since

  BATCH_SIZE = 1000
  private_constant :BATCH_SIZE
end
