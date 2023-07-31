require 'test_helper'

class SerializeAuthorOrContributorsTest < ActiveSupport::TestCase
  test "n+1s handled correctly" do
    create_np1_data

    Bullet.profile do
      SerializeAuthorOrContributors.(User.all)
    end
  end
end
