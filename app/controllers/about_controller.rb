class AboutController < ApplicationController
  skip_before_action :authenticate_user!

  def organisation_supporters
    use_num_individual_supporters
  end

  def individual_supporters
    use_num_individual_supporters
    @badges = User::AcquiredBadge.joins(:user).includes(:user).
      where(badge_id: Badge.find_by_slug!("supporter")). # rubocop:disable Rails/DynamicFindBy
      where(users: { show_on_supporters_page: true }).select(:user_id, :created_at).
      order(id: :asc).
      page(params[:page]).per(30)
  end

  def supporter_gobridge
    @blog_posts = BlogPost.where(slug: 'exercism-is-the-official-go-mentoring-platform')
  end

  #   ips = [
  #     '24.28.78.40',
  #     '137.220.124.51',
  #     '101.102.96.0',
  #     '102.130.40.0',
  #     '1.178.144.0',
  #     '132.174.250.145'
  #   ]
  #   Metrics::SubmitSolutionMetric.last(6).map.with_index do |m, idx|
  #     m.update(
  #       coordinates: Geocoder.search(ips[idx]).first&.coordinates,
  #       track: Track.order('rand()').first
  #     )
  #   end

  def impact; end

  private
  def use_num_individual_supporters
    @num_individual_supporters = User::AcquiredBadge.includes(:user).
      where(badge_id: Badge.find_by_slug!("supporter")). # rubocop:disable Rails/DynamicFindBy
      count
  end
end
