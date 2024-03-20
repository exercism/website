class AboutController < ApplicationController
  skip_before_action :authenticate_user!

  def individual_supporters
    @num_individual_supporters = User::Data.donors.count

    user_ids = User::Data.public_supporter.order(first_donated_at: :asc).
      page(params[:page]).per(30).without_count.
      pluck(:user_id)

    users = User.where(id: user_ids).sort_by { |u| user_ids.index(u.id) }
    @supporting_users = Kaminari.paginate_array(users, total_count: User::Data.public_supporter.count).
      page(params[:page]).per(30)
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

  def testimonials; end

  def impact
    # This is the calculation for the average first iteration time.
    # It comes out at 2594 (seconds) at the time of writing
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
    # So (2_594 * 7_183_572) / 60.0 = 310_569_762
    #
    # There are 6,600 iterations per day, so
    # (2_594 * 6_600) / 60.0 = 285_340

    @contributor_avatars = %w[
      https://avatars3.githubusercontent.com/u/135246
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBME1KQVE9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--cd05313f812251462b308d38018bc127efdc2f1c/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJY0c1bkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--0ce78b9eabfa0afc6e1df3233850ff362c85b5dc/avatar.jpg
      https://avatars1.githubusercontent.com/u/276834
      https://avatars0.githubusercontent.com/u/142262?v=4
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBbk45IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a5c71dc7defd43ac5481401e387244ff9510900c/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJY0c1bkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--0ce78b9eabfa0afc6e1df3233850ff362c85b5dc/avatar.jpg
      https://avatars1.githubusercontent.com/u/1099999?v=4
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBbDhLIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--85c4ddce2d10fd2c488909446e464088ce8e6dd8/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJYW5CbkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--cf22b5230692a68d08c0320d3b3745f81d8aca85/joshjpeg.jpg
      https://avatars.githubusercontent.com/u/1228739
      https://assets.exercism.org/placeholders/user-avatar.svg
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcUJQIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--e1c6d4ff9c5e01c0d42d9e72f0a951f555d6b699/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJYW5CbkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--cf22b5230692a68d08c0320d3b3745f81d8aca85/me_2012.jpg
      https://avatars1.githubusercontent.com/u/122470?v=4
      https://avatars0.githubusercontent.com/u/1964376
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcVVJIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--8e6d52a2d2b0cd98ed806b15170b87203f3d2913/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJYW5CbkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--cf22b5230692a68d08c0320d3b3745f81d8aca85/profile-leek.jpg
      https://avatars3.githubusercontent.com/u/1541915
      https://avatars2.githubusercontent.com/u/346181
      https://secure.gravatar.com/avatar/b932b1e5a3e8299878e579f51f49b84a?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png
      https://avatars0.githubusercontent.com/u/2716614?v=4
      https://avatars2.githubusercontent.com/u/6978003
      https://avatars2.githubusercontent.com/u/7852553
      https://avatars2.githubusercontent.com/u/2488333
      https://avatars0.githubusercontent.com/u/17755913
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBZzFqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--3d00816c345c5b51c6952289e057cb4f56c0c69c/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJY0c1bkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--0ce78b9eabfa0afc6e1df3233850ff362c85b5dc/avatar.jpg
      https://avatars0.githubusercontent.com/u/10479235?v=4
      https://avatars0.githubusercontent.com/u/6624571
      https://avatars0.githubusercontent.com/u/6928620?v=4
      https://avatars2.githubusercontent.com/u/5923094
      https://avatars.githubusercontent.com/u/50879
      https://avatars0.githubusercontent.com/u/3833193
      https://avatars2.githubusercontent.com/u/7275238
      https://avatars2.githubusercontent.com/u/8953691
      https://avatars.githubusercontent.com/u/45465154?v=4
      https://avatars3.githubusercontent.com/u/8198085
      https://avatars1.githubusercontent.com/u/20866761
      https://avatars2.githubusercontent.com/u/966706
      https://avatars2.githubusercontent.com/u/8739328
      https://avatars3.githubusercontent.com/u/8104858
      https://avatars2.githubusercontent.com/u/980783
      https://avatars3.githubusercontent.com/u/1901520
      https://avatars1.githubusercontent.com/u/1910021?v=4
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBaUFaIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a871b69980dc94f8191f3a4a6760b56cf682889f/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJYW5CbkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--cf22b5230692a68d08c0320d3b3745f81d8aca85/Kip2.jpg
      https://avatars1.githubusercontent.com/u/640167
      https://avatars0.githubusercontent.com/u/58951
      https://avatars3.githubusercontent.com/u/30871823
      https://avatars0.githubusercontent.com/u/1400291
      https://avatars0.githubusercontent.com/u/598958
      https://avatars2.githubusercontent.com/u/281700
      https://avatars3.githubusercontent.com/u/7822926
      https://avatars1.githubusercontent.com/u/16987130?v=4
      https://avatars1.githubusercontent.com/u/48602
      https://avatars2.githubusercontent.com/u/10370495?v=4
      https://avatars2.githubusercontent.com/u/17816791
      https://avatars2.githubusercontent.com/u/5096681
      https://avatars3.githubusercontent.com/u/12543047
      https://avatars0.githubusercontent.com/u/4332810?v=4
      https://avatars3.githubusercontent.com/u/9721380
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBaDRwIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--d174614f4f4a1f7e7bf124f267a1b8a59c2a337e/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJY0c1bkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--0ce78b9eabfa0afc6e1df3233850ff362c85b5dc/KarlMarx.png
      https://avatars1.githubusercontent.com/u/2478531
      https://avatars0.githubusercontent.com/u/6539412
      https://avatars2.githubusercontent.com/u/16487165
      https://avatars.githubusercontent.com/u/16929078?v=4
      https://avatars0.githubusercontent.com/u/1794778?v=4
      https://avatars1.githubusercontent.com/u/13311307
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBbDBIIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--4fe6cdcc963f0e3e02e5b38aca1a8e7b77c7be66/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJY0c1bkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--0ce78b9eabfa0afc6e1df3233850ff362c85b5dc/passfoto_vectorized2.png
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDUT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--73d7ea38a93bab1263ac65c31827b4a5964e5b28/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--3536a6556fb76bb6034ca77686f13e3b957f7d0a/IMG_2754.JPG
      https://avatars1.githubusercontent.com/u/6463980
      https://avatars2.githubusercontent.com/u/25203655
      https://avatars1.githubusercontent.com/u/2042030
      https://avatars2.githubusercontent.com/u/212351
      https://avatars3.githubusercontent.com/u/2247219
      https://avatars3.githubusercontent.com/u/6000761?v=4
      https://avatars0.githubusercontent.com/u/616105
      https://avatars1.githubusercontent.com/u/23236642
      https://avatars1.githubusercontent.com/u/6314687
      https://avatars3.githubusercontent.com/u/913480
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBa1luIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--7c653c2c2074a75d08bb1e9b53e51f93402c1751/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJYW5CbkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--cf22b5230692a68d08c0320d3b3745f81d8aca85/BA%CC%88M%20GOLD%202015_Band-7.jpg
      https://exercism.org/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBdklMIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--8c03b1de1ce3572c967410f40659f3c4aaf424ce/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJYW5CbkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWNocEFjZz0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--cf22b5230692a68d08c0320d3b3745f81d8aca85/WP_000099.jpg
      https://avatars2.githubusercontent.com/u/1866448
      https://avatars3.githubusercontent.com/u/8878829
      https://avatars2.githubusercontent.com/u/583354
      https://avatars1.githubusercontent.com/u/22666187
    ]
  end
end
