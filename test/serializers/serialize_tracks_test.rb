require 'test_helper'

class SerializeTracksTest < ActiveSupport::TestCase
  test "sorts by name" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript", slug: :js
    assembly = create :track, title: "Assembly", slug: :ass
    rust = create :track, title: "Rust", slug: :rust

    expected = %w[Assembly Javascript Ruby Rust]
    actual = SerializeTracks.(
      [ruby, javascript, assembly, rust]
    ).map { |t| t[:title] }
    assert_equal expected, actual
  end

  test "sorts by joined then name" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript", slug: :js
    assembly = create :track, title: "Assembly", slug: :ass
    rust = create :track, title: "Rust", slug: :rust

    user = create :user
    create :user_track, user: user, track: rust

    expected = %w[Rust Assembly Javascript Ruby]
    actual = SerializeTracks.(
      [ruby, javascript, assembly, rust],
      user
    ).map { |t| t[:title] }
    assert_equal expected, actual
  end
end
