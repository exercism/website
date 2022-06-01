require "test_helper"

class AssembleTasksTest < ActiveSupport::TestCase
  test "proxies correctly" do
    track = create :track

    actions = ["fix"]
    knowledge = %w[none elementary]
    areas = ["analyzer"]
    sizes = %w[tiny small]
    types = []
    repo_url = "exercism/ruby"
    order = 'recent'
    page = 15

    Github::Task.expects(:count).with.returns(200)

    Github::Task::Search.expects(:call).with(
      actions:,
      knowledge:,
      areas:,
      sizes:,
      types:,
      repo_url:,
      track_id: track.id,
      order:,
      page:
    ).returns(Github::Task.page(1).per(1))

    params = {
      actions:,
      knowledge:,
      areas:,
      sizes:,
      types:,
      repo_url:,
      track_slug: track.slug,
      order:,
      page:,
      sorted: false,
      paginated: false
    }

    AssembleTasks.(params)
  end

  test "retrieves tasks" do
    25.times do |i|
      create :github_task, :random, opened_at: Time.current - i.days
    end

    assert_equal SerializePaginatedCollection.(
      Github::Task.page(1).per(20),
      serializer: SerializeTasks,
      meta: {
        unscoped_total: 25
      }
    ), AssembleTasks.({})
  end
end
