class Exercise::MarkSolutionsAsOutOfDateInIndex
  include Mandate

  queue_as :default

  initialize_with :exercise

  def call
    Exercism.opensearch_client.update_by_query(index: Solution::OPENSEARCH_INDEX, body: {
      script: {
        source: 'ctx._source.out_of_date = true'
      },
      query: {
        bool: {
          must: [
            { term: { 'exercise.id': exercise.id } },
            { term: { 'out_of_date': false } }
          ]
        }
      }
    })
  end
end
