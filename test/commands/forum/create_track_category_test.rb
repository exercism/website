require "test_helper"

class Forum::CreateTrackCategoryTest < ActiveSupport::TestCase
  test "creates with correct position based on title" do
    track = create :track, slug: 'lua', title: 'Lua'

    body = {
      category_list: {
        categories: [
          { name: "C++", position: 1 },
          { name: "Elixir", position: 2 },
          { name: "Nim", position: 3 }
        ]
      }
    }
    stub_request(:get, "https://forum.exercism.org/categories.json?parent_category_id=5").
      to_return(status: 200, body: body.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:post, "https://forum.exercism.org/categories").
      with(body: { "color" => "0088CC", "name" => "Lua", "parent_category_id" => "5", "position" => "3", "text_color" => "FFFFFF" }).
      to_return(status: 200, body: "", headers: {})

    Forum::CreateTrackCategory.(track)
  end

  test "creates with correct position if track should be in first position" do
    track = create :track, slug: 'abap', title: 'ABAP'

    body = {
      category_list: {
        categories: [
          { name: "C++", position: 1 }
        ]
      }
    }
    stub_request(:get, "https://forum.exercism.org/categories.json?parent_category_id=5").
      to_return(status: 200, body: body.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:post, "https://forum.exercism.org/categories").
      with(body: { "color" => "0088CC", "name" => "ABAP", "parent_category_id" => "5", "position" => "1", "text_color" => "FFFFFF" }).
      to_return(status: 200, body: "", headers: {})

    Forum::CreateTrackCategory.(track)
  end

  test "creates with correct position if track should be in last position" do
    track = create :track, slug: 'zig', title: 'Zig'

    body = {
      category_list: {
        categories: [
          { name: "C++", position: 1 }
        ]
      }
    }
    stub_request(:get, "https://forum.exercism.org/categories.json?parent_category_id=5").
      to_return(status: 200, body: body.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:post, "https://forum.exercism.org/categories").
      with(body: { "color" => "0088CC", "name" => "Zig", "parent_category_id" => "5", "position" => "2", "text_color" => "FFFFFF" }).
      to_return(status: 200, body: "", headers: {})

    Forum::CreateTrackCategory.(track)
  end
end
