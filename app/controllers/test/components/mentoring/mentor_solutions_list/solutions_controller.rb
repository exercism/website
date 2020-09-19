class Test::Components::Mentoring::MentorSolutionsList::SolutionsController < ApplicationController
  def index
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    results = [
      {
        trackTitle: "Ruby",
        trackIconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        menteeAvatarUrl: "https://robohash.org/exercism",
        menteeHandle: "mentee",
        exerciseTitle: "Series",
        isStarred: true,
        haveMentoredPreviously: true,
        status: "First timer",
        updatedAt: 1.year.ago.iso8601,
        url: "https://exercism.io/solutions/1"
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
        status: "First timer",
        updatedAt: 1.week.ago.iso8601,
        url: "https://exercism.io/solutions/2"
      },
      {
        trackId: 3,
        trackTitle: "C#",
        trackIconUrl: "https://assets.exercism.io/tracks/csharp-hex-white.png",
        menteeAvatarUrl: "https://robohash.org/exercism_3",
        menteeHandle: "Frank",
        exerciseTitle: "Zipper",
        isStarred: false,
        haveMentoredPreviously: true,
        status: "First timer",
        updatedAt: 1.week.ago.iso8601,
        url: "https://exercism.io/solutions/3"
      }
    ]

    page = params.fetch(:page, 1).to_i
    per = params.fetch(:per, 1).to_i

    if params[:filter].present?
      results = results.select { |result| result[:menteeHandle].downcase.include?(params[:filter].downcase) }
    end
    results = sort(results) if params[:sort].present?

    render json: {
      results: results[page - 1, per],
      meta: { current: page, total: results.size }
    }
  end

  def sort(results)
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
