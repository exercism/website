class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery except: :javascript_browser_test_runner_worker

  before_action :cache_public_action!, only: %i[index]

  def index
    return redirect_to dashboard_path if user_signed_in?

    @num_tracks = Track.num_active
    return unless stale?(etag: @num_tracks)

    @tracks = Track.active.order(num_students: :desc).limit(12).to_a

    @showcase_exercises = [
      {
        exercise: Exercise.new(icon_name: "allergies", title: "Allergies",
          blurb: "Given a person's allergy score, determine whether or not they're allergic to a given item, and their full list of allergies."), # rubocop:disable Layout/LineLength
        num_tracks: 40
      },
      {
        exercise: Exercise.new(icon_name: "queen-attack", title: "Queen Attack",
          blurb: "Given the position of two queens on a chess board, indicate whether or not they are positioned so that they can attack each other"), # rubocop:disable Layout/LineLength
        num_tracks: 60
      },
      {
        exercise: Exercise.new(icon_name: "zebra-puzzle", title: "Zebra Puzzle",
          blurb: "Which of the residents drinks water? Who owns the zebra? Can you solve the Zebra Puzzle with code?"),
        num_tracks: 70
      }
    ]
  end

  def health_check
    user = User.find(User::SYSTEM_USER_ID)

    render json: {
      ruok: true,
      sanity_data: {
        user: user.handle
      }
    }
  end

  def supporter_gobridge
    @blog_posts = BlogPost.where(slug: 'exercism-is-the-official-go-mentoring-platform')
  end

  def ihid
    expires_in 10, public: true unless user_signed_in?
    stale = stale?(etag: 1, skip_custom_logic: true)
    Rails.logger.unknown "|| iHiD: User: #{current_user&.id}, Stale: #{stale}, Time: #{Time.current.to_f}, IP: #{request.remote_ip}, Params: #{params.permit!.to_h}" # rubocop:disable Layout/LineLength
    render json: { "Hello": "iHiD" } if stale
  end

  def javascript_browser_test_runner_worker
    base_path = Rails.root.join('node_modules', '@exercism', 'javascript-browser-test-runner')
    # extract version from the installed package.json file
    pkg_path = base_path.join('package.json')
    version = File.exist?(pkg_path) ? JSON.parse(File.read(pkg_path))['version'] : 'dev'

    return unless stale?(etag: version)

    file_path = base_path.join('output', 'javascript-browser-test-runner-worker.mjs')

    render file: file_path, content_type: 'application/javascript'
  end
end
