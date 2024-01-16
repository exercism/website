require_relative "../react_component_test_case"

class ReactComponents::Contributing::TasksListTest < ReactComponentTestCase
  test "renders correctly" do
    track = create :track, slug: 'ruby'

    task_1 = create(:github_task, issue_url: 'https://github.com/exercism/ruby/issues/888', title: 'Improve test speed',
      opened_at: Time.parse("2021-03-05T23:23:00Z").utc, opened_by_username: 'iHiD',
      action: :fix, knowledge: :elementary, area: :analyzer, size: :tiny, type: :ci,
      repo: 'exercism/ruby', track:)
    task_2 = create(:github_task, issue_url: 'https://github.com/exercism/ruby/issues/312', title: 'Sync anagram',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc, opened_by_username: 'ErikSchierboom',
      action: :fix, knowledge: :none, area: :analyzer, size: :small, type: :ci,
      repo: 'exercism/ruby', track:)

    params = {
      actions: ["fix"],
      knowledge: %w[none elementary],
      areas: ["analyzer"],
      sizes: %w[tiny small],
      types: ["ci"],
      repo_url: "exercism/ruby",
      track_slug: "ruby",
      order: "newest",
      page: 1
    }

    component = ReactComponents::Contributing::TasksList.new(params).to_s

    expected = {
      request: {
        endpoint: Exercism::Routes.api_tasks_url,
        query: params,
        options: {
          initial_data: {
            results: [
              {
                uuid: task_1.uuid,
                title: "Improve test speed",
                tags: {
                  action: "fix",
                  knowledge: "elementary",
                  module: "analyzer",
                  size: "tiny",
                  type: "ci"
                },
                track: {
                  slug: "ruby",
                  title: "Ruby",
                  icon_url: "https://assets.exercism.org/tracks/ruby.svg"
                },
                opened_by_username: "iHiD",
                opened_at: "2021-03-05T23:23:00Z",
                is_new: false,
                links: {
                  github_url: "https://github.com/exercism/ruby/issues/888"
                }
              },
              {
                uuid: task_2.uuid,
                title: "Sync anagram",
                tags: {
                  action: "fix",
                  knowledge: "none",
                  module: "analyzer",
                  size: "small",
                  type: "ci"
                },
                track: {
                  slug: "ruby",
                  title: "Ruby",
                  icon_url: "https://assets.exercism.org/tracks/ruby.svg"
                },
                opened_by_username: "ErikSchierboom",
                opened_at: "2020-10-17T02:39:37Z",
                is_new: false,
                links: {
                  github_url: "https://github.com/exercism/ruby/issues/312"
                }
              }
            ],
            meta: {
              current_page: 1,
              total_count: 2,
              total_pages: 1,
              unscoped_total: 2
            }
          }
        }
      },
      tracks: AssembleTracksForSelect.()
    }
    assert_component component, "contributing-tasks-list", expected
  end
end
