require 'test_helper'

class SerializeMentorDiscussionTest < ActiveSupport::TestCase
  test "with relationship" do
    student = create :user
    relationship = create :mentor_student_relationship, student: student, num_discussions: 5, favorited: true
    expected = {
      id: student.id,
      name: student.name,
      handle: student.handle,
      bio: student.bio,
      languages_spoken: student.languages_spoken,
      avatar_url: student.avatar_url,
      reputation: student.formatted_reputation,
      is_favorite: true,
      num_previous_sessions: 4,
      links: {
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle),
        previous_sessions: Exercism::Routes.api_mentoring_discussions_path(status: :all, student: student.handle)
      }
    }
    assert_equal expected, SerializeStudent.(student, relationship)
  end
  test "without relationship" do
    student = create :user
    expected = {
      id: student.id,
      name: student.name,
      handle: student.handle,
      bio: student.bio,
      languages_spoken: student.languages_spoken,
      avatar_url: student.avatar_url,
      reputation: student.formatted_reputation,
      is_favorite: false,
      num_previous_sessions: 0,
      links: {
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle),
        previous_sessions: Exercism::Routes.api_mentoring_discussions_path(status: :all, student: student.handle)
      }
    }
    assert_equal expected, SerializeStudent.(student, nil)
  end
end
