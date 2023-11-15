require 'test_helper'

class SerializeCodeTagsSampleTest < ActiveSupport::TestCase
  test "serializes code tags sample" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    sample = create(:training_data_code_tags_sample, track:, exercise:)

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
      created_at: sample.created_at,
      updated_at: sample.updated_at,
      links: {
        edit: 'TODO'
      }
    }
    assert_equal expected, SerializeCodeTagsSample.(sample)
  end
end
