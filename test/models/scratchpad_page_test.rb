require 'test_helper'

class ScratchpadPageTest < ActiveSupport::TestCase
  test "generates uuid" do
    page = create :scratchpad_page

    assert page.uuid.present?
  end

  test "#to_param returns uuid" do
    page = create :scratchpad_page

    assert_equal page.uuid, page.to_param
  end
end
