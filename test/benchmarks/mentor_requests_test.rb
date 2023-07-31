require 'test_helper'

module Benchmarks
  class MentorRequestTest < ActiveSupport::TestCase
    # rubocop:disable Performance/TimesMap
    test "stays fast with lots of records" do
      skip # TODO: Work out how to only run this on CI

      mailer = mock
      mailer.stubs(:deliver)
      DeviseMailer.stubs(confirmation_instructions: mailer)

      loads = {
        exercises: 150,
        cancelled: 1_000,
        fulfilled: 10_000,
        locked: 100,
        expired_locks: 1_000,
        pending: 1_000
      }
      mentor = create :user
      track = create :track

      exercises = loads[:exercises].times.map { create(:concept_exercise, track:) }

      # Build solutions for a mentor
      mentor_solutions = loads[:exercises].times.map do |i|
        build(:concept_solution, user: mentor, exercise: exercises[i],
          uuid: i, git_slug: "a", git_sha: "b",
          created_at: Time.current, updated_at: Time.current).attributes
      end
      Solution.insert_all(mentor_solutions)
      mentor_solution_ids = mentor.solutions.pluck(:id)

      mentor_solution_requests = loads[:exercises].times.map do |i|
        build(:mentor_request, solution_id: mentor_solution_ids[i], uuid: i,
          created_at: Time.current, updated_at: Time.current).attributes
      end
      Mentor::Request.insert_all(mentor_solution_requests)

      builder = lambda do |prefix, count, _params|
        start_user_id = User.order(id: :asc).last.id
        users = count.times.map do |_i|
          build(:user,
            created_at: Time.current, updated_at: Time.current).attributes
        end
        User.insert_all(users)
        user_ids = User.where("id > ?", start_user_id).pluck(:id)

        start_solution_id = Solution.order(id: :asc).last.id
        solutions = count.times.map do |i|
          build(:concept_solution, user_id: user_ids[i], exercise: exercises.sample,
            uuid: i, git_slug: "a", git_sha: "b",
            created_at: Time.current, updated_at: Time.current).attributes
        end
        Solution.insert_all(solutions)
        solution_ids = Solution.where("id > ?", start_solution_id).pluck(:id)

        solution_requests = count.times.map do |i|
          build(:mentor_request, solution_id: solution_ids[i], uuid: "#{prefix}-#{i}",
            created_at: Time.current, updated_at: Time.current).attributes
        end
        Mentor::Request.insert_all(solution_requests)
      end

      builder.(:cancelled, loads[:cancelled], status: :cancelled)
      builder.(:fulfilled, loads[:fulfilled], status: :fulfilled)
      builder.(:locked, loads[:locked], locked_until: Time.current - 10.minutes)
      builder.(:expired_locks, loads[:expired_locks], locked_until: Time.current - 10.minutes)
      builder.(:pending, loads[:pending], {})

      t = Time.now.to_f
      results = Mentor::Request::Retrieve.(mentor:, page: 7).to_a
      time_taken = Time.now.to_f - t

      assert_equal 10, results.size # Sanity
      p "MentorRequests::Retrieve | #{time_taken}ms"
    end
    # rubocop:enable Performance/TimesMap
  end
end
