class ChallengesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :use_challenge_id!

  def show
    if user_signed_in? && User::Challenge.where(user: current_user, challenge_id: @challenge_id).exists?
      send("load_data_for_#{@challenge_id}")
      render action: @challenge_id
    else
      render action: "external"
    end
  end

  def start
    begin
      current_user.challenges.create!(challenge_id: @challenge_id)
    rescue ActiveRecord::RecordNotUnique
      # Catch double clicks
    end

    redirect_to action: :show
  end

  private
  def use_challenge_id!
    @challenge_id = params[:id]
    redirect_to root_path unless User::Challenge::CHALLENGES.include?(@challenge_id)
  end

  def load_data_for_12in23 # rubocop:disable Naming/VariableNumber
    @track_counts = Solution.where(
      id: current_user.iterations.where('iterations.created_at >= ?', Date.new(2022, 12, 31)).select(:solution_id)
    ).joins(:exercise).group(:track_id).count
    @track_counts = @track_counts.sort_by(&:second).reverse.to_h
    @tracks = Track.where(id: @track_counts.keys).index_by(&:id)
  end
end
