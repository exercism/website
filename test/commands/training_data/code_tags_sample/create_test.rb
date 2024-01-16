require 'test_helper'

class TrainingData::CodeTagsSample::CreateTest < ActiveSupport::TestCase
  test "creates sample for solution with published submission" do
    solution = create(:practice_solution, :published)
    submission = create(:submission, solution:)
    create(:submission_file, submission:, content: "foo")
    create(:iteration, submission:)

    sample = TrainingData::CodeTagsSample::Create.(solution)

    assert_equal solution, sample.solution
    assert_equal :training, sample.dataset
    assert_equal :untagged, sample.status
  end

  test "does not create sample when no solution has no published submission" do
    solution = create(:practice_solution, published_at: nil)

    TrainingData::CodeTagsSample::Create.(solution)

    refute TrainingData::CodeTagsSample.exists?
  end

  test "does not create sample when published submission does not have files" do
    solution = create(:practice_solution, :published)
    create(:submission, solution:)

    TrainingData::CodeTagsSample::Create.(solution)

    refute TrainingData::CodeTagsSample.exists?
  end

  test "generates tags for solution with published submission" do
    solution = create(:practice_solution, :published)
    submission = create(:submission, solution:)
    create(:submission_file, submission:, content: "foo")
    create(:iteration, submission:)

    TrainingData::CodeTagsSample::GenerateTags.expects(:defer)

    TrainingData::CodeTagsSample::Create.(solution)
  end

  test "does not generate tags when creating validation dataset" do
    solution = create(:practice_solution, :published)
    submission = create(:submission, solution:)
    create(:submission_file, submission:, content: "foo")
    create(:iteration, submission:)

    TrainingData::CodeTagsSample::GenerateTags.expects(:defer).never

    TrainingData::CodeTagsSample::Create.(solution, dataset: :validation)
  end
end
