require "test_helper"

class Locale::NameTest < ActiveSupport::TestCase
  test "gives the endonym and the english name" do
    name = Locale::Name.(:hu)

    assert_equal "magyar", name.native
    assert_equal "Hungarian", name.english
  end

  test "handles a region-suffixed locale" do
    name = Locale::Name.("pt-BR")

    assert_equal "português do Brasil", name.native
    assert_equal "Brazilian Portuguese", name.english
  end

  test "falls back to the code for a language we cannot name" do
    name = Locale::Name.("xx")

    assert_equal "xx", name.native
    assert_equal "xx", name.english
  end

  test "names every locale we serve" do
    I18n.available_locales.each do |locale|
      assert_includes Locale::Name::NAMES.keys, locale.to_s
    end
  end
end
