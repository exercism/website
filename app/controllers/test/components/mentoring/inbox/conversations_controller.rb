class Test::Components::Mentoring::Inbox::ConversationsController < ApplicationController
  def index
    # By passing a state param, we can mock our controller's response.
    # Useful for testing error states in our components.
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    results = [
      {
        track_id: 1,
        track_title: "Ruby",
        track_icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        mentee_avatar_url: "https://robohash.org/exercism",
        mentee_handle: "Mentee",
        exercise_title: "Series",
        is_starred: true,
        have_mentored_previously: true,
        is_new_iteration: true,
        posts_count: 15,
        updated_at: 1.year.ago.iso8601,
        url: "https://exercism.io/conversations/1"
      },
      {
        track_id: 2,
        track_title: "Go",
        track_icon_url: "https://assets.exercism.io/tracks/go-hex-white.png",
        mentee_avatar_url: "https://robohash.org/exercism_2",
        mentee_handle: "User 2",
        exercise_title: "Tournament",
        is_starred: false,
        have_mentored_previously: true,
        is_new_iteration: false,
        posts_count: 22,
        updated_at: 1.week.ago.iso8601,
        url: "https://exercism.io/conversations/2"
      },
      {
        track_id: 3,
        track_title: "C#",
        track_icon_url: "https://assets.exercism.io/tracks/csharp-hex-white.png",
        mentee_avatar_url: "https://robohash.org/exercism_3",
        mentee_handle: "Frank",
        exercise_title: "Zipper",
        is_starred: false,
        have_mentored_previously: false,
        is_new_iteration: false,
        posts_count: 5,
        updated_at: 1.month.ago.iso8601,
        url: "https://exercism.io/conversations/3"
      }
    ]

    results = results.select { |c| c[:track_id] == params[:track].to_i } if params[:track].present?
    if params[:filter].present?
      parts = params[:filter].downcase.split(' ').map(&:strip)
      results = results.select do |c|
        parts.all? do |part|
          c[:exercise_title].downcase.include?(part) || c[:mentee_handle].downcase.include?(part)
        end
      end
    end
    results = sort(results)

    page = params.fetch(:page, 1).to_i
    per = params.fetch(:per, 1).to_i

    render json: {
      results: results[page - 1, per],
      meta: { current: page, total: results.size }
    }
  end

  def sort(results)
    case params[:sort]
    when 'exercise'
      results.sort_by { |c| c[:exercise_title] }
    when 'recent'
      results.sort_by { |c| c[:updated_at] }.reverse
    else
      results.sort_by { |c| c[:mentee_handle] }
    end
  end
end
