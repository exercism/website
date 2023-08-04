require "test_helper"

class Track::TrophyTest < ActiveSupport::TestCase
  test "for_track" do
    ruby = create :track, slug: :ruby
    js = create :track, slug: :javascript
    haskell = create :track, slug: :haskell

    Track::Trophies::EmptySlugs.create!
    Track::Trophies::RubySlug.create!
    Track::Trophies::HaskellSlug.create!
    Track::Trophies::MultipleSlugs.create!

    assert_equal [Track::Trophies::EmptySlugs, Track::Trophies::RubySlug],
      Track::Trophy.for_track(ruby).map(&:class)

    assert_equal [Track::Trophies::EmptySlugs],
      Track::Trophy.for_track(js).map(&:class)

    assert_equal [Track::Trophies::EmptySlugs, Track::Trophies::HaskellSlug, Track::Trophies::MultipleSlugs],
      Track::Trophy.for_track(haskell).map(&:class)
  end

  class Track::Trophies::EmptySlugs < Track::Trophy
  end

  class Track::Trophies::RubySlug < Track::Trophy
    def self.valid_track_slugs = [:ruby]
  end

  class Track::Trophies::HaskellSlug < Track::Trophy
    def self.valid_track_slugs = [:haskell]
  end

  class Track::Trophies::MultipleSlugs < Track::Trophy
    def self.valid_track_slugs = %i[haskell fsharp]
  end
end
