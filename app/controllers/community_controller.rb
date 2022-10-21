class CommunityController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    # TODO: add caching
    @supporter_avatar_urls =
      User::AcquiredBadge.joins(:user).
        where(badge_id: Badge.find_by_slug!("supporter")). # rubocop:disable Rails/DynamicFindBy
        where(users: { show_on_supporters_page: true }).
        last(40).
        map { |b| b.user.avatar_url }

    @community_stories = CommunityStory.includes(:interviewee).ordered_by_recency.first(3)
  end

  def show
    @title = 'How I Saved My Life with 3D Printing'
    # rubocop:disable Layout/LineLength
    @description = 'Listen to the story of how Bobbi went from being on the streets, to getting back on their feet in the face of adversity.'
    @transcript = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec laoreet nibh odio. Pellentesque eu posuere enim. Fusce in diam quis eros pellentesque imperdiet. Donec eget diam pharetra massa vehicula placerat. Fusce sagittis sem vitae nunc pharetra, at dignissim neque rhoncus. Proin leo leo, fringilla at sapien ac, vestibulum sollicitudin sem. Curabitur sed massa sapien. Maecenas maximus ornare leo, id hendrerit dui rhoncus a.  Morbi tincidunt ullamcorper dolor nec interdum. Nunc sed elit et dui aliquet blandit id sed arcu. Fusce sollicitudin sed mi facilisis vestibulum. Etiam non dapibus arcu. Suspendisse eleifend nunc felis, vel pulvinar quam condimentum in. Sed molestie nibh non est vulputate, nec pharetra ligula congue. Proin luctus elementum pulvinar. Pellentesque lacinia scelerisque nisi, at tincidunt leo lacinia vel. In ultrices blandit libero a pharetra.  Mauris dapibus porta neque. In ullamcorper consequat semper. Curabitur convallis efficitur gravida. Etiam pulvinar, turpis vitae tincidunt pretium, lectus augue luctus erat, sed elementum risus lorem eu quam. Pellentesque vitae aliquam ligula. Nullam cursus orci id dignissim scelerisque. Maecenas eget volutpat eros. Vivamus consequat lacus et lectus pharetra, nec porta magna aliquam. Donec vulputate, sem sed ultrices maximus, tellus purus scelerisque magna, tincidunt tempor quam ex a ex. Fusce efficitur ac lacus sit amet lacinia. Nullam ullamcorper leo a massa volutpat tempor.  Sed tincidunt massa ligula, vitae vehicula nisl mollis nec. Aliquam erat volutpat. In molestie volutpat mattis. Integer condimentum elementum suscipit. Praesent eleifend elit sed quam pulvinar, in iaculis ipsum sodales. In hac habitasse platea dictumst. Donec posuere magna sed suscipit ultricies. Praesent convallis lorem nec odio pulvinar viverra.  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec laoreet nibh odio. Pellentesque eu posuere enim. Fusce in diam quis eros pellentesque imperdiet. Donec eget diam pharetra massa vehicula placerat. Fusce sagittis sem vitae nunc pharetra, at dignissim neque rhoncus. Proin leo leo, fringilla at sapien ac, vestibulum sollicitudin sem. Curabitur sed massa sapien. Maecenas maximus ornare leo, id hendrerit dui rhoncus a.  Morbi tincidunt ullamcorper dolor nec interdum. Nunc sed elit et dui aliquet blandit id sed arcu. Fusce sollicitudin sed mi facilisis vestibulum. Etiam non dapibus arcu. Suspendisse eleifend nunc felis, vel pulvinar quam condimentum in. Sed molestie nibh non est vulputate, nec pharetra ligula congue. Proin luctus elementum pulvinar. Pellentesque lacinia scelerisque nisi, at tincidunt leo lacinia vel. In ultrices blandit libero a pharetra.  Mauris dapibus porta neque. In ullamcorper consequat semper. Curabitur convallis efficitur gravida. Etiam pulvinar, turpis vitae tincidunt pretium, lectus augue luctus erat, sed elementum risus lorem eu quam. Pellentesque vitae aliquam ligula. Nullam cursus orci id dignissim scelerisque. Maecenas eget volutpat eros. Vivamus consequat lacus et lectus pharetra, nec porta magna aliquam. Donec vulputate, sem sed ultrices maximus, tellus purus scelerisque magna, tincidunt tempor quam ex a ex. Fusce efficitur ac lacus sit amet lacinia. Nullam ullamcorper leo a massa volutpat tempor.  Sed tincidunt massa ligula, vitae vehicula nisl mollis nec. Aliquam erat volutpat. In molestie volutpat mattis. Integer condimentum elementum suscipit. Praesent eleifend elit sed quam pulvinar, in iaculis ipsum sodales. In hac habitasse platea dictumst. Donec posuere magna sed suscipit ultricies. Praesent convallis lorem nec odio pulvinar viverra.'
    @interviewer_icon_url = 'https://avatars.githubusercontent.com/u/58132850?v=4'
    @interviewee_icon_url = 'https://avatars.githubusercontent.com/u/24420806?v=4'
    # rubocop:enable Layout/LineLength
  end
end
