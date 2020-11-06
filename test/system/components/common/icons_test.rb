require "application_system_test_case"

module Components
  module Common
    class IconsTest < ApplicationSystemTestCase
      test "icon renders correctly" do
        visit test_components_common_icons_path

        assert_selector '.c-icon'
      end

      test "graphical icon renders correctly" do
        visit test_components_common_icons_path

        assert_selector '.c-icon'
      end
    end
  end
end
