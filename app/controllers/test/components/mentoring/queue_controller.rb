class Test::Components::Mentoring::QueueController < Test::BaseController
  def show; end

  def solutions
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    requests = [
      {
        track_title: "Ruby",
        track_icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        mentee_avatar_url: "https://robohash.org/exercism",
        mentee_handle: "mentee",
        exercise_title: "Series",
        is_starred: true,
        have_mentored_previously: true,
        status: "First timer",
        updated_at: 1.year.ago.iso8601,
        url: "https://exercism.io/solutions/1",
        tooltip_url: mentored_student_test_components_tooltips_tooltip_path(1)
      },
      {
        trackId: 2,
        track_title: "Go",
        track_icon_url: "https://assets.exercism.io/tracks/go-hex-white.png",
        mentee_avatar_url: "https://robohash.org/exercism_2",
        mentee_handle: "User 2",
        exercise_title: "Tournament",
        is_starred: false,
        have_mentored_previously: true,
        status: "First timer",
        updated_at: 1.week.ago.iso8601,
        url: "https://exercism.io/solutions/2",
        tooltip_url: mentored_student_test_components_tooltips_tooltip_path(2)
      },
      {
        trackId: 3,
        track_title: "C#",
        track_slug: "csharp",
        exercise_slug: "zipper",
        track_icon_url: "https://assets.exercism.io/tracks/csharp-hex-white.png",
        mentee_avatar_url: "https://robohash.org/exercism_3",
        mentee_handle: "Frank",
        exercise_title: "Zipper",
        is_starred: false,
        have_mentored_previously: true,
        status: "First timer",
        updated_at: 1.week.ago.iso8601,
        url: "https://exercism.io/solutions/3",
        tooltip_url: mentored_student_test_components_tooltips_tooltip_path(3)
      }
    ]

    results = requests

    page = params.fetch(:page, 1).to_i
    per = params.fetch(:per, 1).to_i

    if params[:criteria].present?
      results = results.select { |result| result[:mentee_handle].downcase.include?(params[:criteria].downcase) }
    end
    results = sort_solutions(results) if params[:order].present?

    results = filter_solutions(results) if params[:filter]

    render json: {
      results: results[page - 1, per],
      meta: { current: page, unscoped_total: results.size, total: requests.size }
    }
  end

  def sort_solutions(results)
    case params[:order]
    when 'exercise'
      results.sort_by { |c| c[:exercise_title] }
    when 'recent'
      results.sort_by { |c| c[:updated_at] }.reverse
    else
      results.sort_by { |c| c[:mentee_handle] }
    end
  end

  def filter_solutions(results)
    tracks = params[:filter][:track] || []
    exercises = params[:filter][:exercise] || []

    results = results.select { |c| tracks.include?(c[:track_slug]) } if tracks.any?

    results = results.select { |c| exercises.include?(c[:exercise_slug]) } if exercises.any?

    results
  end
end
