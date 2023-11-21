require 'test_helper'

class SerializeCodeTagsSamplesTest < ActiveSupport::TestCase
  test "serializes code tags samples" do
    sample_1 = create :training_data_code_tags_sample
    sample_2 = create :training_data_code_tags_sample
    status = :needs_checking

    expected = [
      SerializeCodeTagsSample.(sample_1, status:),
      SerializeCodeTagsSample.(sample_2, status:)
    ]

    assert_equal expected, SerializeCodeTagsSamples.(TrainingData::CodeTagsSample.all, status:)
  end
end
