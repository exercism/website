class Solution::CreateSearchIndexDocument
  include Mandate

  initialize_with :solution

  def call
    {
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
        tests_status: published_iteration.tests_status,
        head_tests_status: solution.published_iteration_head_tests_status,
        code: published_iteration.submission.files.map(&:content) || []
      } : nil,
      latest_iteration: latest_iteration ? {
        tests_status: latest_iteration.tests_status,
        head_tests_status: solution.latest_iteration_head_tests_status,
        code: latest_iteration.submission.files.map(&:content) || []
      } : nil
    }
  end

  memoize
  def published_iteration
    return nil unless solution.published?

    solution.published_iteration || solution.latest_iteration
  end

  memoize
  delegate :latest_iteration, to: :solution
end
