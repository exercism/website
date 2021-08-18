require 'test_helper'

class SerializeSolutionCommentsTest < ActiveSupport::TestCase
  test "basic request" do
    comment = create :solution_comment
    for_user = create :user

    expected = [SerializeSolutionComment.(comment, for_user)]

    assert_equal expected, SerializeSolutionComments.(Solution::Comment.all, for_user)
  end
end
