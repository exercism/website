class Test::Components::Mentoring::InboxController < ApplicationController
  def show
    @sort_options = [
      { value: 'recent', label: 'Sort by Most Recent' },
      { value: 'exercise', label: 'Sort by Exercise' },
      { value: 'student', label: 'Sort by Student' }
    ]
  end

  def tracks
    # By passing a state param, we can mock our controller's response.
    # Useful for testing error states in our components.
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    results = [
      {
        id: 1,
        title: "Ruby",
        iconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png"
      },
      {
        id: 2,
        title: "Go",
        iconUrl: "https://assets.exercism.io/tracks/go-hex-white.png"
      }
    ]

    render json: results
  end

  def conversations
    # By passing a state param, we can mock our controller's response.
    # Useful for testing error states in our components.
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    results = [
      {
        trackId: 1,
        trackTitle: "Ruby",
        trackIconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        menteeAvatarUrl: "https://robohash.org/exercism",
        menteeHandle: "Mentee",
        exerciseTitle: "Series",
        isStarred: true,
        haveMentoredPreviously: true,
        isNewIteration: true,
        postsCount: 15,
        updatedAt: 1.year.ago.iso8601,
        url: "https://exercism.io/conversations/1"
      },
      {
        trackId: 2,
        trackTitle: "Go",
        trackIconUrl: "https://assets.exercism.io/tracks/go-hex-white.png",
        menteeAvatarUrl: "https://robohash.org/exercism_2",
        menteeHandle: "User 2",
        exerciseTitle: "Tournament",
        isStarred: false,
        haveMentoredPreviously: true,
        isNewIteration: false,
        postsCount: 22,
        updatedAt: 1.week.ago.iso8601,
        url: "https://exercism.io/conversations/2"
      },
      {
        trackId: 3,
        trackTitle: "C#",
        trackIconUrl: "https://assets.exercism.io/tracks/csharp-hex-white.png",
        menteeAvatarUrl: "https://robohash.org/exercism_3",
        menteeHandle: "Frank",
        exerciseTitle: "Zipper",
        isStarred: false,
        haveMentoredPreviously: false,
        isNewIteration: false,
        postsCount: 5,
        updatedAt: 1.month.ago.iso8601,
        url: "https://exercism.io/conversations/3"
      }
    ]

    results = results.select { |c| c[:trackId] == params[:track].to_i } if params[:track].present?

    if params[:filter].present?
      parts = params[:filter].downcase.split(' ').map(&:strip)
      results = results.select do |c|
        parts.all? do |part|
          c[:exerciseTitle].downcase.include?(part) || c[:menteeHandle].downcase.include?(part)
        end
      end
    end

    results = sort_conversations(results)

    page = params.fetch(:page, 1).to_i
    per = params.fetch(:per, 1).to_i

    render json: {
      results: results[page - 1, per],
      meta: { current: page, total: results.size }
    }
  end

  private
  def sort_conversations(results)
    case params[:sort]
    when 'exercise'
      results.sort_by { |c| c[:exerciseTitle] }
    when 'recent'
      results.sort_by { |c| c[:updatedAt] }.reverse
    else
      results.sort_by { |c| c[:menteeHandle] }
    end
  end
end
