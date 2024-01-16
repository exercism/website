require 'test_helper'

class SerializeDocTest < ActiveSupport::TestCase
  test "serialize track doc" do
    freeze_time do
      track = create :track, slug: 'fsharp', title: "F#"
      doc = create(:document, slug: 'ruby/install', title: 'Ruby', blurb: 'Install Ruby', track:)

      expected = {
        uuid: doc.uuid,
        title: 'Ruby',
        blurb: 'Install Ruby',
        track: {
          slug: 'fsharp',
          title: 'F#',
          icon_url: 'https://assets.exercism.org/tracks/fsharp.svg'
        },
        updated_at: Time.current.iso8601,
        links: {
          self: 'https://test.exercism.org/docs/contributing/ruby/install'
        }
      }
      assert_equal expected, SerializeDoc.(doc)
    end
  end

  test "serialize non-track doc" do
    freeze_time do
      doc = create :document, slug: 'mentoring', title: 'Mentoring', blurb: 'How to mentor'

      expected = {
        uuid: doc.uuid,
        title: 'Mentoring',
        blurb: 'How to mentor',
        track: nil,
        updated_at: Time.current.iso8601,
        links: {
          self: 'https://test.exercism.org/docs/contributing/mentoring'
        }
      }
      assert_equal expected, SerializeDoc.(doc)
    end
  end
end
