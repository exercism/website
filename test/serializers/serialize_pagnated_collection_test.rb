require 'test_helper'

class SerializePaginatedCollectionTest < ActiveSupport::TestCase
  test "adds meta" do
    results = { foo: 'bar' }
    collection_serializer = mock
    collection_serializer.expects(:call).returns(results)

    5.times { create :user }
    collection = User.page(2).per(2)

    expected = {
      results:,
      meta: {
        current_page: 2,
        total_pages: 3,
        total_count: 5
      }
    }
    actual = SerializePaginatedCollection.(
      collection,
      serializer: collection_serializer
    )
    assert_equal expected, actual
  end

  test "respects data over serializer" do
    collection_serializer = mock
    collection_serializer.expects(:call).never
    data = [{ preserialized: true }, { yay: false }]

    5.times { create :user }
    collection = User.page(2).per(2)

    expected = {
      results: data,
      meta: {
        current_page: 2,
        total_pages: 3,
        total_count: 5
      }
    }
    actual = SerializePaginatedCollection.(
      collection,
      serializer: collection_serializer,
      data:
    )
    assert_equal expected, actual
  end

  test "can override meta" do
    results = { foo: 'bar' }
    collection_serializer = mock
    collection_serializer.expects(:call).returns(results)

    5.times { create :user }
    collection = User.page(2).per(2)

    expected = {
      results:,
      meta: {
        misc: "Hello",
        current_page: 7,
        total_count: 5,
        total_pages: 3
      }
    }
    actual = SerializePaginatedCollection.(
      collection,
      serializer: collection_serializer,
      meta: {
        current_page: 7,
        misc: "Hello"
      }
    )
    assert_equal expected, actual
  end
end
