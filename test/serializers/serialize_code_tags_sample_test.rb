require 'test_helper'

class SerializeCodeTagsSampleTest < ActiveSupport::TestCase
  test "serializes code tags sample" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    sample = create(:training_data_code_tags_sample, track:, exercise:)
    status = :needs_checking

    expected = {
      uuid: sample.uuid,
      status: sample.status,
      track: {
        title: track.title,
        icon_url: track.icon_url
      },
      exercise: {
        title: exercise.title,
        icon_url: exercise.icon_url
      },
      links: {
        edit: Exercism::Routes.training_data_code_tags_sample_url(sample, status:)
      }
    }
    assert_equal expected, SerializeCodeTagsSample.(sample, status:)
  end
end
