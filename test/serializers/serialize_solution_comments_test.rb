require 'test_helper'

class SerializeSolutionCommentsTest < ActiveSupport::TestCase
  test "basic request" do
    comment_1 = create :solution_comment
    comment_2 = create :solution_comment
    for_user = create :user

    expected = [
      SerializeSolutionComment.(comment_1, for_user),
      SerializeSolutionComment.(comment_2, for_user)
    ]

    assert_equal expected, SerializeSolutionComments.(Solution::Comment.all, for_user)
  end

  test "n+1s handled correctly" do
    create_np1_data

    Bullet.profile do
      SerializeSolutionComments.(Solution::Comment.all, create(:user))
    end
  end
end
