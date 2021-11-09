class Exercise::MarkSolutionsAsOutOfDateInIndex
  include Mandate

  initialize_with :exercise

  def call
    client.update_by_query(index: 'solutions', body: {
      script: {
        source: 'ctx._source.out_of_date = true'
      },
      query: {
        bool: {
          must: [
            { term: { 'exercise_id': exercise.id } },
            { term: { 'out_of_date': false } }
          ]
        }
      }
    })
  end

  private
  def client
    # TODO: use Exercism.opensearch_client once the config gem has been updated
    Elasticsearch::Client.new(
      url: ENV['OPENSEARCH_HOST'],
      user: ENV['OPENSEARCH_USER'],
      password: ENV['OPENSEARCH_PASSWORD'],
      transport_options: { ssl: { verify: ENV['OPENSEARCH_VERIFY_SSL'] != 'false' } }
    )
  end
end
