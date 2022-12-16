require 'test_helper'

class Tooling::Representer::HandleDeployTest < ActiveSupport::TestCase
  test "when representer version changed create representer job for each representation with feedback" do
    track = create :track, :random_slug, representer_version: 1
    other_track = create :track, :random_slug

    representation_1 = create :exercise_representation, :with_feedback, exercise: create(:practice_exercise, track:)
    representation_2 = create :exercise_representation, :with_feedback, exercise: create(:practice_exercise, track:)
    representation_3 = create :exercise_representation, :with_feedback, exercise: create(:practice_exercise, track:)

    # Sanity check: don't queue job for representation with same track but without feedback
    create :exercise_representation, exercise: create(:practice_exercise, track:)

    # Sanity check: don't queue job for representation with feedback but for different track
    create :exercise_representation, :with_feedback, exercise: create(:practice_exercise, track: other_track)

    Submission::Representation::Init.expects(:call).with(representation_1.source_submission, type: :exercise,
      git_sha: representation_1.source_submission.exercise.git_sha, run_in_background: true).once
    Submission::Representation::Init.expects(:call).with(representation_2.source_submission, type: :exercise,
      git_sha: representation_2.source_submission.exercise.git_sha, run_in_background: true).once
    Submission::Representation::Init.expects(:call).with(representation_3.source_submission, type: :exercise,
      git_sha: representation_3.source_submission.exercise.git_sha, run_in_background: true).once

    Tooling::Representer::HandleDeploy.(track)
  end

  test "when representer version does not change no representer jobs are created" do
    track = create :track, :random_slug, representer_version: 2

    create :exercise_representation, :with_feedback, exercise: create(:practice_exercise, track:)

    Submission::Representation::Init.expects(:call).never

    Tooling::Representer::HandleDeploy.(track)
  end

  test "update representer version" do
    track = create :track

    Track::UpdateRepresenterVersion.expects(:call).with(track)

    Tooling::Representer::HandleDeploy.(track)
  end
end
