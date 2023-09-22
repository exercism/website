class API::Exercises::MakersController < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user
  before_action :use_exercise

  # TODO: (Optional) This needs test coverage
  def index
    mapper = proc do |user|
      {
        avatar_url: user.avatar_url,
        handle: user.handle,
        flair: user.flair,
        reputation: user.formatted_reputation,
        links: {
          self: user.profile ? profile_url(user) : nil
        }
      }
    end

    render json: {
      authors: @exercise.authors.includes(:profile).map { |author| mapper.(author) },
      contributors: @exercise.contributors.includes(:profile).map { |contributor| mapper.(contributor) },
      links: {
        github: "https://github.com/exercism/#{@track.slug}/commits/main/exercises/#{@exercise.git_type}/#{@exercise.slug}"
      }
    }
  end

  private
  def use_exercise
    @track = Track.find(params[:track_slug])
    @exercise = @track.exercises.find(params[:exercise_slug])
  end
end
