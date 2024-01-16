class CommunityController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @supporter_avatar_urls = AVATAR_URLS
    @community_stories = CommunityStory.published.includes(:interviewee).ordered_by_recency.first(3)
    @forum_threads = Forum::RetrieveThreads.(type: :top, count: 2)
  end

  # TODO: Let's cache this daily instead.
  # TOOD: This has moved to user_data now
  # Generated with
  #  User.public_supporter.
  #    where.not('users.avatar_url': nil).
  #    order(first_donated_at: :desc).
  #    pluck(:avatar_url).
  #    last(40)
  AVATAR_URLS = [
    "https://avatars0.githubusercontent.com/u/14336279",
    "https://avatars0.githubusercontent.com/u/43811589?v=4",
    "https://avatars2.githubusercontent.com/u/2698319?v=4",
    "https://avatars.githubusercontent.com/u/19652894?v=4",
    "https://avatars3.githubusercontent.com/u/45837",
    "https://avatars.githubusercontent.com/u/26220782?v=4",
    "https://avatars.githubusercontent.com/u/54382508?v=4",
    "https://avatars.githubusercontent.com/u/6928620?v=4",
    "https://avatars3.githubusercontent.com/u/3067960?v=4",
    "https://avatars1.githubusercontent.com/u/12924528?v=4",
    "https://avatars0.githubusercontent.com/u/1964376",
    "https://avatars.githubusercontent.com/u/16072194?v=4",
    "https://avatars2.githubusercontent.com/u/22743599?v=4",
    "https://avatars.githubusercontent.com/u/22623360?v=4",
    "https://avatars.githubusercontent.com/u/2065286?v=4",
    "https://avatars0.githubusercontent.com/u/267115",
    "https://avatars3.githubusercontent.com/u/33209457?v=4",
    "https://avatars.githubusercontent.com/u/69643273?v=4",
    "https://avatars1.githubusercontent.com/u/13915810?v=4",
    "https://avatars3.githubusercontent.com/u/35175560?v=4",
    "https://avatars1.githubusercontent.com/u/50366",
    "https://avatars2.githubusercontent.com/u/2882",
    "https://avatars2.githubusercontent.com/u/86504?v=4",
    "https://avatars2.githubusercontent.com/u/18352529",
    "https://avatars0.githubusercontent.com/u/32323021",
    "https://avatars.githubusercontent.com/u/7881288?v=4",
    "https://avatars1.githubusercontent.com/u/10376340?v=4",
    "https://avatars.githubusercontent.com/u/6298183",
    "https://avatars0.githubusercontent.com/u/9129843",
    "https://avatars.githubusercontent.com/u/2993937",
    "https://avatars.githubusercontent.com/u/5023727",
    "https://avatars3.githubusercontent.com/u/3275302?v=4",
    "https://avatars2.githubusercontent.com/u/10552804?v=4",
    "https://avatars3.githubusercontent.com/u/7255934",
    "https://avatars2.githubusercontent.com/u/10026538?v=4",
    "https://avatars3.githubusercontent.com/u/5421823",
    "https://avatars.githubusercontent.com/u/41840506?v=4",
    "https://avatars2.githubusercontent.com/u/7852553",
    "https://avatars1.githubusercontent.com/u/5337876?v=4",
    "https://avatars2.githubusercontent.com/u/286476"
  ].freeze
end
