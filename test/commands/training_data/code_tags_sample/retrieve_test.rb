require 'test_helper'

class TrainingData::CodeTagsSample::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves samples with specified statuses" do
    untagged = create :training_data_code_tags_sample, status: :untagged
    machine_tagged = create :training_data_code_tags_sample, status: :machine_tagged
    admin_checked = create :training_data_code_tags_sample, status: :admin_checked

    assert_equal [untagged], TrainingData::CodeTagsSample::Retrieve.(:untagged)
    assert_equal [machine_tagged], TrainingData::CodeTagsSample::Retrieve.(:machine_tagged)
    assert_equal [machine_tagged, admin_checked], TrainingData::CodeTagsSample::Retrieve.(%i[admin_checked machine_tagged]).order(:id)
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
