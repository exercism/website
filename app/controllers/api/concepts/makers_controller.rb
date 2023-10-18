class API::Concepts::MakersController < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user
  before_action :use_concept

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
      authors: @concept.authors.includes(:profile).map { |author| mapper.(author) },
      contributors: @concept.contributors.includes(:profile).map { |contributor| mapper.(contributor) },
      links: {
        github: "https://github.com/exercism/#{@track.slug}/commits/main/concepts/#{@concept.slug}"
      }
    }
  end

  private
  def use_concept
    @track = Track.find(params[:track_slug])
    @concept = @track.concepts.find(params[:concept_slug])
  end
end
