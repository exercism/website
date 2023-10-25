require_relative "../react_component_test_case"
MOCK_TAGS = [
  'construct:char',
  'construct:class',
  'construct:implicit-conversion',
  'construct:int',
  'construct:integral-number',
  'construct:invocation',
  'construct:lambda',
  'construct:linq',
  'construct:method',
  'construct:number',
  'construct:parameter',
  'construct:return',
  'construct:string',
  'construct:using-directive',
  'construct:visibility-modifiers',
  'paradigm:functional',
  'paradigm:object-oriented',
  'technique:higher-order-functions',
  'uses:Enumerable.GroupBy'
].freeze

class ReactComponents::Track::ExerciseCommunitySolutionsListTest < ReactComponentTestCase
  test "mentoring request renders correctly" do
    exercise = create :practice_exercise
    component = ReactComponents::Track::ExerciseCommunitySolutionsList.new(exercise, params)

    def group_tags(tag_list)
      grouped_tags = {}

      tag_list.each do |tag|
        key, = tag.split(':', 2)
        grouped_tags[key] ||= []
        grouped_tags[key] << tag
      end

      grouped_tags.transform_keys(&:capitalize)
    end

    def mock_tags = group_tags(MOCK_TAGS)

    assert_component(
      render(component),
      "track-exercise-community-solutions-list",
      {
        request: {
          endpoint: "https://test.exercism.org/api/v2/tracks/ruby/exercises/bob/community_solutions",
          query: {},
          options: { initial_data: {
            results: [],
            meta: { current_page: 1,
                    total_count: 0,
                    total_pages: 0,
                    unscoped_total: 0 }
          } }
        },
        tags: mock_tags

      }
    )
  end
end
