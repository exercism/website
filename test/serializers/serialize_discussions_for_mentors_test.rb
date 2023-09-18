require 'test_helper'

class SerializeMentorDiscussionsForMentorTest < ActiveSupport::TestCase
  test "n+1s handled correctly" do
    mentor = create :user
    create_np1_data(mentor:)

    Bullet.profile do
      SerializeMentorDiscussionsForMentor.(Mentor::Discussion.all, mentor)
    end
  end
end
