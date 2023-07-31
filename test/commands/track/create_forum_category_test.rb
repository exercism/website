require "test_helper"

class Track::CreateForumCategoryTest < ActiveSupport::TestCase
  test "creates as correct position based on alphabetical order" do
    track = create :track, slug: 'lua', title: 'Lua'

    get_categories_body = {
      category_list: {
        categories: [
          { position: 1, name: "C++", slug: "cpp" },
          { position: 2, name: "Elixir", slug: "elixir" },
          { position: 3, name: "Nim", slug: "nim" }
        ]
      }
    }
    stub_request(:get, "https://forum.exercism.org/categories.json?parent_category_id=5").
      to_return(status: 200, body: get_categories_body.to_json, headers: { 'Content-Type': 'application/json' })

    post_category_body = { category: { position: 3, name: "C++", topic_url: "/t/about-the-cpp-category/105" } }
    stub_request(:post, "https://forum.exercism.org/categories").
      with(body: { "color" => "0088CC", "name" => "Lua", "slug" => "lua", "parent_category_id" => "5", "position" => "3",
                   "text_color" => "FFFFFF" }).
      to_return(status: 200, body: post_category_body.to_json, headers: { 'Content-Type': 'application/json' })

    get_topic_body = { post_stream: { posts: [{ id: 22 }] } }
    stub_request(:get, "https://forum.exercism.org/t/105.json").
      to_return(status: 200, body: get_topic_body.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://forum.exercism.org/posts/22").
      to_return(status: 200, body: "", headers: {})

    Track::CreateForumCategory.(track)
  end

  test "creates in first position if first in alphabetical order" do
    track = create :track, slug: 'abap', title: 'ABAP'

    get_categories_body = {
      category_list: {
        categories: [
          { position: 1, name: "C++", slug: "cpp" },
          { position: 2, name: "Elixir", slug: "elixir" },
          { position: 3, name: "Nim", slug: "nim" }
        ]
      }
    }
    stub_request(:get, "https://forum.exercism.org/categories.json?parent_category_id=5").
      to_return(status: 200, body: get_categories_body.to_json, headers: { 'Content-Type': 'application/json' })

    post_category_body = { category: { position: 1, name: "ABAP", slug: "abap", topic_url: "/t/about-the-abap-category/105" } }
    stub_request(:post, "https://forum.exercism.org/categories").
      with(body: { "color" => "0088CC", "name" => "ABAP", "slug" => "abap", "parent_category_id" => "5", "position" => "1",
                   "text_color" => "FFFFFF" }).
      to_return(status: 200, body: post_category_body.to_json, headers: { 'Content-Type': 'application/json' })

    get_topic_body = { post_stream: { posts: [{ id: 22 }] } }
    stub_request(:get, "https://forum.exercism.org/t/105.json").
      to_return(status: 200, body: get_topic_body.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://forum.exercism.org/posts/22").
      to_return(status: 200, body: "", headers: {})

    Track::CreateForumCategory.(track)
  end

  test "creates in last position if last in alphabetical order" do
    track = create :track, slug: 'zig', title: 'Zig'

    get_categories_body = {
      category_list: {
        categories: [
          { position: 1, name: "C++" },
          { position: 2, name: "Elixir" },
          { position: 3, name: "Nim" }
        ]
      }
    }
    stub_request(:get, "https://forum.exercism.org/categories.json?parent_category_id=5").
      to_return(status: 200, body: get_categories_body.to_json, headers: { 'Content-Type': 'application/json' })

    post_category_body = { category: { position: 4, name: "Zig", slug: "zig", topic_url: "/t/about-the-zig-category/105" } }
    stub_request(:post, "https://forum.exercism.org/categories").
      with(body: { "color" => "0088CC", "name" => "Zig", "slug" => "zig", "parent_category_id" => "5", "position" => "4",
                   "text_color" => "FFFFFF" }).
      to_return(status: 200, body: post_category_body.to_json, headers: { 'Content-Type': 'application/json' })

    get_topic_body = { post_stream: { posts: [{ id: 22 }] } }
    stub_request(:get, "https://forum.exercism.org/t/105.json").
      to_return(status: 200, body: get_topic_body.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://forum.exercism.org/posts/22").
      to_return(status: 200, body: "", headers: {})

    Track::CreateForumCategory.(track)
  end

  test "correctly edits first post" do
    track = create :track, slug: 'lua', title: 'Lua'

    get_categories_body = { category_list: { categories: [] } }
    stub_request(:get, "https://forum.exercism.org/categories.json?parent_category_id=5").
      to_return(status: 200, body: get_categories_body.to_json, headers: { 'Content-Type': 'application/json' })

    post_category_body = { category: { position: 1, name: "Lua", slug: "lua", topic_url: "/t/about-the-lua-category/105" } }
    stub_request(:post, "https://forum.exercism.org/categories").
      with(body: { "color" => "0088CC", "name" => "Lua", "slug" => "lua", "parent_category_id" => "5", "position" => "1",
                   "text_color" => "FFFFFF" }).
      to_return(status: 200, body: post_category_body.to_json, headers: { 'Content-Type': 'application/json' })

    get_topic_body = { post_stream: { posts: [{ id: 22 }] } }
    stub_request(:get, "https://forum.exercism.org/t/105.json").
      to_return(status: 200, body: get_topic_body.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://forum.exercism.org/posts/22").
      with(body: { "post" => { "raw" => "Welcome to the Lua category. This is a space to ask any Lua questions, discuss exercises from the Exercism Lua track, or explore any other Lua-related conversations!" } }). # rubocop:disable Layout/LineLength
      to_return(status: 200, body: "", headers: {})

    Track::CreateForumCategory.(track)
  end
end
