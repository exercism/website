class Exercise::MarkSolutionsAsOutOfDateInIndex
  include Mandate

  initialize_with :exercise

  def call
    # Clear out opensearch
    Exercism.opensearch_client.update_by_query(index: "#{Exercism.env}-solutions", body: {
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
end
