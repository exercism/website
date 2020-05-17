require 'test_helper'

class IterationTest < ActiveSupport::TestCase
  test "statuses start at pending" do
    iteration = create :iteration
    assert iteration.tests_pending?
    assert iteration.representation_pending?
    assert iteration.analysis_pending?
  end
end
