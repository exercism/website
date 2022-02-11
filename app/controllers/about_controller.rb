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

  private
  def use_num_individual_supporters
    @num_individual_supporters = User::AcquiredBadge.joins(:user).includes(:user).
      where(badge_id: Badge.find_by_slug!("supporter")). # rubocop:disable Rails/DynamicFindBy
      count
  end
end
