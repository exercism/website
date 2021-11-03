class Search::IndexSolution
  include Mandate

  initialize_with :exercise

  def call
    # TODO: add this information to the body
    # code
    # published iteration (last if multiple)
    # uptodate?(latest)
    # tests_pass?(latest)
    # hash change of exercise then published solution are not up-to-date anymore
    # public comments
    # mentoring

    body = {
      id: solution.id,
      exercise_slug: solution.exercise.slug,
      track_slug: solution.track.slug,
      author_handle: solution.author.handle,
      created_at: solution.createdAt,
      published_at: solution.publishedAt,
      num_stars: solution.num_stars,
      num_loc: solution.num_loc
    }

    client.index(index: 'solutions', type: 'solutions', body: body)

    # client.search(index: 'books', q: 'galaxy', field: 'name')
  end

  private
  memoize
  def iteration
    solution.published_iteration || solution.latest_iteration
  end

  def client
    Elasticsearch::Client.new url: 'https://localhost:9200',
      user: 'admin',
      password: 'admin',
      log: true,
      transport_options: {
        ssl: { verify: false }
      }
  end
end
