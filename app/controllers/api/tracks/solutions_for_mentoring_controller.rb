class API::Tracks::SolutionsForMentoringController < API::BaseController
  def index
    track = Track.find(params[:track_slug])
    solutions = Track::SearchSolutionsForMentoring.(current_user, track, page: params[:page])

    render json: SerializePaginatedCollection.(
      solutions,
      serializer: SerializeSolutions,
      serializer_args: [current_user]
    )
  end
end
