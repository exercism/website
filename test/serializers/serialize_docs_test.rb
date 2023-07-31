require 'test_helper'

class SerializeDocsTest < ActiveSupport::TestCase
  test "serializes docs" do
    freeze_time do
      doc_1 = create :document
      doc_2 = create :document
      docs = [doc_1, doc_2]

      expected = [
        SerializeDoc.(doc_1),
        SerializeDoc.(doc_2)
      ]
      assert_equal expected, SerializeDocs.(docs)
    end
  end

  test "n+1s handled correctly" do
    create :document, track: create(:track, :random_slug)
    create :document, track: create(:track, :random_slug)

    Bullet.profile do
      SerializeDocs.(Document.all)
    end
  end
end
