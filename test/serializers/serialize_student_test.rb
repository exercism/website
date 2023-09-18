require 'test_helper'

class SerializeStudentTest < ActiveSupport::TestCase
  test "with relationship" do
    Mentor::StudentRelationship::ToggleFavorited.any_instance.stubs(:allowed?).returns(true)
    student = create :user
    mentor = create :user
    relationship = create :mentor_student_relationship, student:, num_discussions: 5, favorited: true
    3.times { create :mentor_discussion, solution: create(:practice_solution, user: student) }
    expected = {
      handle: student.handle,
      flair: student.flair,
      name: student.name,
      bio: nil,
      location: nil,
      languages_spoken: %w[english spanish],
      avatar_url: student.avatar_url,
      reputation: student.formatted_reputation,
      pronouns: nil,
      is_favorited: true,
      is_blocked: false,
      track_objectives: "",
      num_total_discussions: 3,
      num_discussions_with_mentor: 5,
      links: {
        block: Exercism::Routes.block_api_mentoring_student_path(student.handle),
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle),
        previous_sessions: Exercism::Routes.api_mentoring_discussions_path(status: :all, student: student.handle)
      }
    }
    assert_equal expected, SerializeStudent.(
      student,
      mentor,
      user_track: nil,
      relationship:,
      anonymous_mode: false
    )
  end

  test "without relationship" do
    Mentor::StudentRelationship::ToggleFavorited.any_instance.stubs(:allowed?).returns(true)
    student = create :user
    mentor = create :user
    expected = {
      handle: student.handle,
      flair: student.flair,
      name: student.name,
      bio: nil,
      location: nil,
      languages_spoken: student.languages_spoken,
      avatar_url: student.avatar_url,
      reputation: student.formatted_reputation,
      pronouns: nil,
      is_favorited: false,
      is_blocked: false,
      track_objectives: "",
      num_total_discussions: 0,
      num_discussions_with_mentor: 0,
      links: {
        block: Exercism::Routes.block_api_mentoring_student_path(student.handle),
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle),
        previous_sessions: Exercism::Routes.api_mentoring_discussions_path(status: :all, student: student.handle)
      }
    }
    assert_equal expected, SerializeStudent.(
      student,
      mentor,
      user_track: nil,
      relationship: nil,
      anonymous_mode: nil
    )
  end

  test "anonymous_mode" do
    student = create :user
    mentor = create :user

    expected = {
      name: "User in Anonymous mode",
      handle: "anonymous",
      reputation: 0,
      num_discussions_with_mentor: 0
    }
    assert_equal expected, SerializeStudent.(
      student,
      mentor,
      user_track: nil,
      relationship: nil,
      anonymous_mode: true
    )
  end

  test "bio, location, rep" do
    bio = "some bio"
    location = "some loc"
    student = create :user, bio:, location:, reputation: 12_345
    mentor = create :user

    result = SerializeStudent.(
      student,
      mentor,
      user_track: nil,
      relationship: nil,
      anonymous_mode: false
    )

    assert_equal bio, result[:bio]
    assert_equal location, result[:location]
    assert_equal "12.3k", result[:reputation]
  end

  test "track_objectives" do
    objectives = "some objectives"
    user_track = create(:user_track, objectives:)

    result = SerializeStudent.(
      create(:user),
      create(:user),
      user_track:,
      relationship: nil,
      anonymous_mode: false
    )

    assert_equal objectives, result[:track_objectives]
  end

  test "pronouns" do
    user = create :user, pronouns: "he/him/his"
    user_track = create(:user_track, user:)

    result = SerializeStudent.(
      user,
      create(:user),
      user_track:,
      relationship: nil,
      anonymous_mode: false
    )

    assert_equal %w[he him his], result[:pronouns]
  end
end
