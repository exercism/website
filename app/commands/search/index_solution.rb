class Search::IndexSolution
  include Mandate

  initialize_with :solution

  def call
    # TODO: add this information to the body
    # code
    # public comments
    # mentoring
    # hash change of exercise then published solution are not up-to-date anymore

    body = {
      id: solution.id,
      exercise_slug: solution.exercise.slug,
      track_slug: solution.track.slug,
      author_handle: solution.user.handle,
      created_at: solution.created_at,
      published_at: solution.published_at,
      num_stars: solution.num_stars,
      num_loc: solution.num_loc,
      out_of_date: solution.out_of_date?,
      tests_passed: iteration&.submission&.tests_passed?
    }

    client.index(index: 'solutions', type: 'solution', body: body)
  end

  private
  memoize
  def iteration
    solution.published_iteration || solution.latest_iteration
  end

  def client
    Elasticsearch::Client.new url: ENV.fetch('OPENSEARCH_HOST', 'https://localhost:9200'),
      user: ENV.fetch('OPENSEARCH_USER', 'admin'),
      password: ENV.fetch('OPENSEARCH_PASSWORD', 'admin'),
      log: true,
      transport_options: {
        ssl: { verify: false }
      }
  end
end
