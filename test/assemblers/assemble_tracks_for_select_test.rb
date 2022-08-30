require 'test_helper'

class AssembleTracksForSelectTest < ActiveSupport::TestCase
  test "ordered by title ascending" do
    track_1 = create :track, slug: :csharp, title: 'C#'
    track_2 = create :track, slug: :ruby, title: 'Ruby'
    track_3 = create :track, slug: :javascript, title: 'JavaScript'
    track_4 = create :track, slug: :clojure, title: 'Clojure'
    expected = [
      SerializeTrackForSelect::ALL_TRACK,
      SerializeTrackForSelect.(track_1),
      SerializeTrackForSelect.(track_4),
      SerializeTrackForSelect.(track_3),
      SerializeTrackForSelect.(track_2)
    ]
    actual = AssembleTracksForSelect.()
    assert_equal expected, actual
  end

  test "specify tracks" do
    track_1 = create :track, slug: :csharp, title: 'C#'
    track_2 = create :track, slug: :ruby, title: 'Ruby'
    track_3 = create :track, slug: :javascript, title: 'JavaScript'
    track_4 = create :track, slug: :clojure, title: 'Clojure'
    expected = [
      SerializeTrackForSelect::ALL_TRACK,
      SerializeTrackForSelect.(track_1),
      SerializeTrackForSelect.(track_3),
      SerializeTrackForSelect.(track_2)
    ]
    actual = AssembleTracksForSelect.(Track.where.not(slug: track_4.slug))
    assert_equal expected, actual
  end
end
