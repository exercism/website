class ImagesController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'images'

  def profile
    @user = User.find_by!(handle: params[:user_handle])
    @profile = @user&.profile

    return render_404 unless @profile

    track_ids = User::ReputationPeriod.where(
      user: @user,
      period: :forever,
      about: :track,
      category: :any
    ).order(reputation: :desc).limit(3).pluck(:track_id)

    @top_three_tracks = ::Track.active.where(id: track_ids).sort_by { |t| track_ids.index(t.id) }

    @header_tags = []
    @header_tags << { class: "tag staff", icon: :logo, title: "Exercism Staff" } if @user.staff?
    @header_tags << { class: "tag maintainer", icon: :maintaining, title: "Maintainer" } if @user.maintainer?
    @header_tags << { class: "tag insider", icon: :insiders, title: "Insider" } if @user.insider?
    @header_tags = @header_tags.take(2)
  end

  def solution
    @solution = Solution.for!(params[:user_handle], params[:track_slug], params[:exercise_slug])
  end
end
