require "test_helper"

class Mentoring::DiscussionsControllerTest < ActionDispatch::IntegrationTest
  test "redirects non mentors" do
    user = create :user, :not_mentor
    sign_in!(user)

    get mentoring_discussion_path(1)
    assert_redirected_to mentoring_path
  end

  test "redirects different mentor" do
    mentor = create :user
    sign_in!(mentor)

    discussion = create :mentor_discussion
    get mentoring_discussion_path(discussion)
    assert_redirected_to mentoring_path
  end

  test "redirects maintainer" do
    maintainer = create :user, :maintainer
    sign_in!(maintainer)

    discussion = create :mentor_discussion
    get mentoring_discussion_path(discussion)
    assert_redirected_to mentoring_path
  end

  test "shows for correct mentor" do
    mentor = create :user
    sign_in!(mentor)

    solution = create :concept_solution
    discussion = create(:mentor_discussion, mentor:, solution:)
    create(:iteration, solution:)
    get mentoring_discussion_path(discussion)
    assert_response :ok
  end

  test "shows for admin" do
    admin = create :user, :admin
    sign_in!(admin)

    solution = create :concept_solution
    discussion = create(:mentor_discussion, solution:)
    create(:iteration, solution:)
    get mentoring_discussion_path(discussion)
    assert_response :ok
  end
end
