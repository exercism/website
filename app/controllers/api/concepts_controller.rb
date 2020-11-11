module API
  class ConceptsController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user

    def show
      track = Track.find_by!(slug: params[:track_id])
      concept = track.concepts.find_by!(slug: params[:id])

      render json: {
        concept: {
          slug: concept.slug,
          blurb: concept.blurb
        }
      }
    end
  end
end
