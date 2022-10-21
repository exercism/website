class ReactComponents::Community::StoriesGrid < ReactComponents::ReactComponent
  def initialize(params)
    super()

    @params = params
  end

  def to_s
    super("community-stories-grid", {
      request: {
        endpoint: Exercism::Routes.api_community_stories_url,
        query:,
        options: {
          initial_data:
        }
      }
    })
  end

  private
  attr_reader :params

  memoize
  def initial_data = AssembleCommunityStories.(params)

  memoize
  def query = { page: current_page }.compact

  memoize
  def current_page
    page = initial_data[:meta][:current_page]

    page != 1 ? page : nil
  end
end
