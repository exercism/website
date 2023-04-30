require 'test_helper'

class SerializeIterationsTest < ActiveSupport::TestCase
  test "n+1s handled correctly" do
    create_np1_solutions

    Bullet.profile do
      SerializeIterations.(Iteration.all)
    end
  end
end
