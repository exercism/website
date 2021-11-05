class Solution::Index
  include Mandate

  initialize_with :solution

  def call
    body = {
      id: solution.id,
      last_iterated_at: solution.last_iterated_at,
      published_at: solution.published_at,
      num_stars: solution.num_stars,
      num_loc: solution.num_loc,
      num_comments: solution.num_comments,
      num_views: solution.num_views,
      out_of_date: solution.out_of_date?,
      status: solution.status,
      mentoring_status: solution.mentoring_status,
      exercise: {
        id: solution.exercise.id,
        slug: solution.exercise.slug,
        title: solution.exercise.title
      },
      track: {
        id: solution.track.id,
        slug: solution.track.slug,
        title: solution.track.title
      },
      user: {
        id: solution.user.id,
        handle: solution.user.handle
      },
      published_iteration: published_iteration ? {
        tests_passed: published_iteration.submission.tests_passed?,
        code: published_iteration.submission.files.map(&:content) || []
      } : nil,
      latest_iteration: latest_iteration ? {
        tests_passed: latest_iteration.submission.tests_passed?,
        code: latest_iteration.submission.files.map(&:content) || []
      } : nil
    }

    client.index(index: 'solutions', type: 'solution', body: body)
  end

  private
  memoize
  def published_iteration
    solution.published_iterations.last
  end

  memoize
  def latest_iteration
    solution.latest_iteration
  end

  def client
    Elasticsearch::Client.new(
      url: ENV['OPENSEARCH_HOST'],
      user: ENV['OPENSEARCH_USER'],
      password: ENV['OPENSEARCH_PASSWORD'],
      transport_options: { ssl: { verify: ENV['OPENSEARCH_VERIFY_SSL'] != 'false' } }
    )
  end
end
