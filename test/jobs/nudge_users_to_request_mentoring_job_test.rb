require "test_helper"

class NudgeUsersToRequestMentoringJobTest < ActiveJob::TestCase
  test "correct users get solution" do
    # Set things up for the correct user
    ruby = create :track, slug: :ruby
    javascript = create :track, slug: :javascript
    user = create :user
    create :iteration, created_at: 2.days.ago, solution: create(:practice_solution, track: javascript, user:, status: :iterated)
    create :iteration, created_at: 2.days.ago, solution: create(:practice_solution, track: ruby, user:, status: :completed)

    # Too recent
    create :iteration, created_at: 5.minutes.ago, solution: create(:practice_solution)

    # Too old
    create :iteration, created_at: Date.new(2021, 8, 15), solution: create(:practice_solution)

    # Hello world
    create :iteration, created_at: 2.days.ago, solution: create(:hello_world_solution)

    # Concept solution
    create :iteration, created_at: 2.days.ago, solution: create(:concept_solution)

    # Has requested mentoring
    u = create :user
    s = create(:practice_solution, user: u)
    create :iteration, created_at: 2.days.ago, solution: s
    create :mentor_request, solution: s

    # Already had notification
    u = create :user
    create :iteration, created_at: 2.days.ago, solution: create(:practice_solution, user: u)
    create :nudge_to_request_mentoring_notification, user: u, track: ruby

    # Only expect call with the initial correct user. This will raise if called with any other user.
    User::Notification::Create.expects(:call).with(user, :nudge_to_request_mentoring, track: ruby)
    NudgeUsersToRequestMentoringJob.perform_now
  end
end
