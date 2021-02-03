require 'test_helper'

class SerializePaginatedCollectionTest < ActiveSupport::TestCase
  test "adds meta" do
    results = { foo: 'bar' }
    collection_serializer = mock
    collection_serializer.expects(:call).returns(results)

    5.times { create :user }
    collection = User.page(2).per(1)

    expected = {
      results: results,
      meta: {
        current: 2,
        total: 5
      }
    }
    actual = SerializePaginatedCollection.(collection, collection_serializer)
    assert_equal expected, actual
  end

  test "can override meta" do
    results = { foo: 'bar' }
    collection_serializer = mock
    collection_serializer.expects(:call).returns(results)

    5.times { create :user }
    collection = User.page(2).per(1)

    expected = {
      results: results,
      meta: {
        current: 7,
        misc: "Hello",
        total: 5
      }
    }
    actual = SerializePaginatedCollection.(
      collection,
      collection_serializer,
      meta: {
        current: 7,
        misc: "Hello"
      }
    )
    assert_equal expected, actual
  end
end
