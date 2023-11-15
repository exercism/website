require 'test_helper'

class SerializeCodeTagsSamplesTest < ActiveSupport::TestCase
  test "serializes code tags samples" do
    sample_1 = create :training_data_code_tags_sample
    sample_2 = create :training_data_code_tags_sample

    expected = [
      SerializeCodeTagsSample.(sample_1),
      SerializeCodeTagsSample.(sample_2)
    ]

    assert_equal expected, SerializeCodeTagsSamples.(TrainingData::CodeTagsSample.all)
  end
end
