class Test::Components::Mentoring::QueueController < Test::BaseController
  def show; end

  def solutions
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    results = [
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

    page = params.fetch(:page, 1).to_i
    per = params.fetch(:per, 1).to_i

    if params[:criteria].present?
      results = results.select { |result| result[:mentee_handle].downcase.include?(params[:criteria].downcase) }
    end
    results = sort_solutions(results) if params[:order].present?

    results = filter_solutions(results) if params[:filter] && params[:filter][:track].present?

    tracks = [
      {
        slug: 'csharp',
        title: 'C#',
        iconUrl: 'https://assets.exercism.io/tracks/ruby-hex-white.png',
        count: 52
      },
      {
        slug: 'ruby',
        title: 'Ruby',
        iconUrl: 'https://assets.exercism.io/tracks/ruby-hex-white.png',
        count: 52
      }
    ]

    render json: {
      results: results[page - 1, per],
      tracks: tracks,
      meta: { current: page, total: results.size }
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
    selected = params[:filter][:track]
    results.select { |c| selected.include?(c[:track_slug]) }
  end
end
