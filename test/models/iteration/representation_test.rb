require 'test_helper'

class Iteration::RepresentationTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:iteration_representation, ops_status: 199).ops_success?
    assert create(:iteration_representation, ops_status: 200).ops_success?
    refute create(:iteration_representation, ops_status: 201).ops_success?
  end

  test "ops_errored?" do
    assert create(:iteration_representation, ops_status: 199).ops_errored?
    refute create(:iteration_representation, ops_status: 200).ops_errored?
    assert create(:iteration_representation, ops_status: 201).ops_errored?
  end
end
