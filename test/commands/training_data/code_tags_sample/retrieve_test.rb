require 'test_helper'

class TrainingData::CodeTagsSample::RetrieveTest < ActiveSupport::TestCase
  test "filter: status" do
    untagged = create :training_data_code_tags_sample, status: :untagged
    machine_tagged = create :training_data_code_tags_sample, status: :machine_tagged
    admin_checked = create :training_data_code_tags_sample, status: :admin_checked

    assert_equal [untagged], TrainingData::CodeTagsSample::Retrieve.(:untagged)
    assert_equal [machine_tagged], TrainingData::CodeTagsSample::Retrieve.(:machine_tagged)
    assert_equal [machine_tagged, admin_checked], TrainingData::CodeTagsSample::Retrieve.(%i[admin_checked machine_tagged]).order(:id)
  end

  test "filter: dataset" do
    training = create :training_data_code_tags_sample, status: :untagged, dataset: :training
    validation = create :training_data_code_tags_sample, status: :untagged, dataset: :validation

    assert_equal [training], TrainingData::CodeTagsSample::Retrieve.(:untagged, dataset: :training)
    assert_equal [validation], TrainingData::CodeTagsSample::Retrieve.(:untagged, dataset: :validation)
    assert_equal [training], TrainingData::CodeTagsSample::Retrieve.(:untagged)
  end

  test "filter: track" do
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    track_sample = create(:training_data_code_tags_sample, status: :untagged, track:)
    other_track_sample = create(:training_data_code_tags_sample, status: :untagged, track: other_track)

    assert_equal [track_sample], TrainingData::CodeTagsSample::Retrieve.(:untagged, track:)
    assert_equal [other_track_sample], TrainingData::CodeTagsSample::Retrieve.(:untagged, track: other_track)
    assert_equal [track_sample, other_track_sample], TrainingData::CodeTagsSample::Retrieve.(:untagged, track: nil).order(:id)
    assert_equal [track_sample, other_track_sample], TrainingData::CodeTagsSample::Retrieve.(:untagged).order(:id)
  end

  test "filter: criteria" do
    anagram = create :practice_exercise, slug: 'anagram'
    isogram = create :practice_exercise, slug: 'isogram'
    anagram_sample = create(:training_data_code_tags_sample, status: :untagged, exercise: anagram)
    isogram_sample = create(:training_data_code_tags_sample, status: :untagged, exercise: isogram)

    assert_equal [anagram_sample], TrainingData::CodeTagsSample::Retrieve.(:untagged, criteria: 'anagram')
    assert_equal [isogram_sample], TrainingData::CodeTagsSample::Retrieve.(:untagged, criteria: 'iso')
    assert_equal [anagram_sample, isogram_sample], TrainingData::CodeTagsSample::Retrieve.(:untagged, criteria: 'gram').order(:id)
  end

  test "pagination" do
    samples = create_list(:training_data_code_tags_sample, 25, status: :untagged)

    retrieved = TrainingData::CodeTagsSample::Retrieve.(:untagged)
    assert_equal 1, retrieved.current_page
    assert_equal 2, retrieved.total_pages
    assert_equal 20, retrieved.limit_value
    assert_equal 25, retrieved.total_count
    assert_equal samples.take(20), retrieved

    retrieved = TrainingData::CodeTagsSample::Retrieve.(:untagged, page: 1)
    assert_equal 1, retrieved.current_page
    assert_equal 2, retrieved.total_pages
    assert_equal 20, retrieved.limit_value
    assert_equal 25, retrieved.total_count
    assert_equal samples.take(20), retrieved

    retrieved = TrainingData::CodeTagsSample::Retrieve.(:untagged, page: 2)
    assert_equal 2, retrieved.current_page
    assert_equal 2, retrieved.total_pages
    assert_equal 20, retrieved.limit_value
    assert_equal 25, retrieved.total_count
    assert_equal samples.drop(20), retrieved
  end

  test "raises when no status is specified" do
    assert_raises do
      TrainingData::CodeTagsSample::Retrieve.(nil)
    end

    assert_raises do
      TrainingData::CodeTagsSample::Retrieve.([])
    end
  end
end
