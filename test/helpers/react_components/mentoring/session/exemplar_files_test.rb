require_relative "../../../../../app/helpers/react_components/mentoring/session/exemplar_file_list"

module ReactComponents
  module Mentoring
    class Session
      class ExemplarFileListTest < ActiveSupport::TestCase
        test "#as_json serializes files" do
          files = {
            ".meta/exemplar1.rb" => "class Ruby\nend"
          }

          assert_equal(
            [
              {
                filename: "exemplar1.rb",
                content: "class Ruby\nend"
              }
            ],
            Mentoring::Session::ExemplarFileList.new(files).as_json
          )
        end
      end
    end
  end
end
