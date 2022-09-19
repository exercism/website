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

  #     ips = [
  #       '24.28.78.40',
  #       '137.220.124.51',
  #       '101.102.96.0',
  #       '102.130.40.0',
  #       '1.178.144.0',
  #       '132.174.250.145'
  #     ]
  #     Metrics::PublishSolutionMetric.last(6).map.with_index do |m, idx|
  #       m.update(
  #         coordinates: Geocoder.search(ips[idx]).first&.coordinates,
  #         track: Track.order('rand()').first
  #       )
  #     end

  def impact
    # This is the calculation for the average first iteration time.
    # It comes out at 1450 (seconds) at the time of writing
    #
    # SELECT AVG(dd.val) as median_val
    # FROM (
    #   SELECT d.val, @rownum:=@rownum+1 as `row_number`, @total_rows:=@rownum
    #     FROM (
    #       SELECT iterations.created_at - solutions.created_at as val
    #       FROM `solutions`
    #       INNER JOIN iterations ON iterations.id = (
    #         SELECT id from iterations WHERE solutions.id = solution_id order by id ASC LIMIT 1
    #       )
    #       INNER JOIN exercises ON solutions.exercise_id = exercises.id
    #       WHERE exercises.slug != "hello-world"
    #       HAVING val < 7200
    #       ORDER BY solutions.id desc LIMIT 100000
    #     ) d, (SELECT @rownum:=0) r
    #   ORDER BY d.val
    # ) as dd
    # WHERE dd.row_number IN ( FLOOR((@total_rows+1)/2), FLOOR((@total_rows+2)/2) );
    #
    # There are 4,312,556 iteratiions at the time of writing.
    # I am presuming each iteration has roughly the same amount of time
    # go into it based on learning/mentoring but this bit is the most
    # sketchy, but we have no other way to measure it currently.
    #
    # So (1_450 * 4_312_556) / 60.0 = 104_220_130
    #
    # There are 5,500 iterations per day, so
    # (1_450 * 5_500) / 60.0 = 132_916
  end

  private
  def use_num_individual_supporters
    @num_individual_supporters = User::AcquiredBadge.includes(:user).
      where(badge_id: Badge.find_by_slug!("supporter")). # rubocop:disable Rails/DynamicFindBy
      count
  end
end
