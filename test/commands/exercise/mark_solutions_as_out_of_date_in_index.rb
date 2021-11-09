require "test_helper"

class Exercise::MarkSolutionsAsOutOfDateInIndexTest < ActiveSupport::TestCase
  test "mark all solutions of an exercise as out of date in index" do
    track = create :track, slug: 'fsharp'
    exercise = create :practice_exercise, id: 7, track: track

    stub_request(:post, "https://opensearch:9200/solutions/_update_by_query").
      with(
        body: {
          script: {
            source: 'ctx._source.out_of_date = true'
          },
          query: {
            bool: {
              must: [
                { term: { 'exercise_id': 7 } },
                { term: { 'out_of_date': false } }
              ]
            }
          }
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Exercise::MarkSolutionsAsOutOfDateInIndex.(exercise)
  end
end
