class Admin::CommunityVideosController < ApplicationController
  before_action :set_community_video, only: %i[show edit update destroy]

  # GET /admin/community_videos
  def index
    @community_videos = CommunityVideo.all
  end

  # GET /admin/community_videos/1
  def show; end

  # GET /admin/community_videos/new
  def new
    @community_video = CommunityVideo.new
  end

  # GET /admin/community_videos/1/edit
  def edit; end

  # POST /admin/community_videos
  def create
    @community_video = CommunityVideo.new(community_video_params)

    if @community_video.save
      redirect_to @community_video, notice: "Community video was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/community_videos/1
  def update
    if @community_video.update(community_video_params)
      redirect_to @community_video, notice: "Community video was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/community_videos/1
  def destroy
    @community_video.destroy
    redirect_to community_videos_url, notice: "Community video was successfully destroyed."
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_community_video
    @community_video = CommunityVideo.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def community_video_params
    params.fetch(:community_video, {})
  end
end
