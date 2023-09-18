require "test_helper"

class Maintaining::ExerciseRepresentationsControllerTest < ActionDispatch::IntegrationTest
  test "index - redirects non maintainers" do
    user = create :user
    sign_in!(user)

    get maintaining_exercise_representations_path
    assert_redirected_to root_path
  end

  test "index - shows for maintainer" do
    user = create :user, :maintainer
    sign_in!(user)

    get maintaining_exercise_representations_path
    assert_response :ok
  end

  test "edit - redirects non maintainers" do
    representation = create :exercise_representation
    user = create :user
    sign_in!(user)

    get edit_maintaining_exercise_representation_path(representation.id)
    assert_redirected_to root_path
  end

  test "edit - shows for maintainer" do
    submission = create :submission
    create(:iteration, submission:)
    create :submission_file, submission:, filename: "src/stub.rb", content: "Stub"
    representation = create :exercise_representation, source_submission: submission
    user = create :user, :maintainer
    sign_in!(user)

    get edit_maintaining_exercise_representation_path(representation.id)
    assert_response :ok
  end
end
