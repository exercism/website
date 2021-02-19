require 'test_helper'

class Tracks::ShowExternalTest < ActionDispatch::IntegrationTest
  test "the instructions are shown for a concept exercise" do
    create :concept_exercise
    get "/tracks/ruby/exercises/strings/"
    assert_select ".instructions", text: /You have three tasks/
  end

  test "the instructions are shown for a practice exercise" do
    create :practice_exercise
    get "/tracks/ruby/exercises/bob/"
    assert_select ".instructions", text: /Instructions for bob/
  end

  test "the introduction is not shown for a concept exercise" do
    create :concept_exercise
    get "/tracks/ruby/exercises/strings/"
    assert_select ".introduction", false
  end

  test "the introduction is shown for a practice exercise that has an introduction" do
    create :practice_exercise
    get "/tracks/ruby/exercises/bob/"
    assert_select ".introduction", text: /Introduction for bob/
  end

  test "the introduction is not shown for a practice exercise without an introduction" do
    create :practice_exercise, slug: 'allergies'
    get "/tracks/ruby/exercises/allergies/"
    assert_select ".introduction", false
  end

  test "the source is shown" do
    create :practice_exercise
    get "/tracks/ruby/exercises/bob/"
    assert_select ".source", text: /Inspired by the 'Deaf Grandma' exercise/
  end

  test "the source_url is shown" do
    create :practice_exercise
    get "/tracks/ruby/exercises/bob/"
    assert_select ".source", text: %r{http://pine.fm/LearnToProgram/\?Chapter=06}
  end
end
