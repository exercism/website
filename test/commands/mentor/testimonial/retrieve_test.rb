require 'test_helper'

class Mentor::Testimonial::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves mentors testimonials" do
    mentor = create :user
    create :mentor_testimonial, :revealed
    testimonial = create(:mentor_testimonial, :revealed, mentor:)

    assert_equal [testimonial], Mentor::Testimonial::Retrieve.(mentor:)
  end

  test "only retrieves not_deleted testimonials" do
    mentor = create :user
    testimonial = create :mentor_testimonial, :revealed, mentor:, deleted_at: nil
    create :mentor_testimonial, :revealed, mentor:, deleted_at: Time.current

    assert_equal [testimonial], Mentor::Testimonial::Retrieve.(mentor:)
  end

  test "honours include_unrevealed" do
    mentor = create :user
    revealed = create(:mentor_testimonial, :revealed, mentor:)
    unrevealed = create(:mentor_testimonial, :unrevealed, mentor:)

    assert_equal [revealed], Mentor::Testimonial::Retrieve.(mentor:)
    assert_equal [unrevealed, revealed], Mentor::Testimonial::Retrieve.(mentor:, include_unrevealed: true)
  end

  test "only retrieves from correct tracks" do
    mentor = create :user

    ruby = create :track, slug: "ruby"
    js = create :track, slug: "js"

    ruby_bob = create :concept_exercise, track: ruby, slug: "bob"
    js_bob = create :concept_exercise, track: js, slug: "bob"

    ruby_strings = create :concept_exercise, track: ruby, slug: "strings"
    js_strings = create :concept_exercise, track: js, slug: "strings"

    ruby_bob_req = create(:mentor_testimonial, solution: create(:concept_solution, exercise: ruby_bob), mentor:)
    js_bob_req = create(:mentor_testimonial, solution: create(:concept_solution, exercise: js_bob), mentor:)
    ruby_strings_req = create(:mentor_testimonial, solution: create(:concept_solution, exercise: ruby_strings),
      mentor:)
    js_strings_req = create(:mentor_testimonial, solution: create(:concept_solution, exercise: js_strings), mentor:)

    assert_equal [
      js_strings_req, ruby_strings_req, js_bob_req, ruby_bob_req
    ], Mentor::Testimonial::Retrieve.(mentor:, include_unrevealed: true) # Sanity

    assert_equal [ruby_strings_req, ruby_bob_req],
      Mentor::Testimonial::Retrieve.(mentor:, track_slug: ruby.slug, include_unrevealed: true)
  end

  test "orders correctly" do
    mentor = create :user

    first = create(:mentor_testimonial, :revealed, mentor:)
    second = create(:mentor_testimonial, :unrevealed, mentor:)
    third = create(:mentor_testimonial, :revealed, mentor:)

    assert_equal [second, third, first], Mentor::Testimonial::Retrieve.(mentor:, include_unrevealed: true)
    assert_equal [first, second, third],
      Mentor::Testimonial::Retrieve.(mentor:, order: :oldest, include_unrevealed: true)
    assert_equal [third, second, first],
      Mentor::Testimonial::Retrieve.(mentor:, order: :newest, include_unrevealed: true)
  end

  test "pagination works" do
    mentor = create :user
    25.times { create :mentor_testimonial, mentor: }

    testimonials = Mentor::Testimonial::Retrieve.(mentor:, include_unrevealed: true, page: 2)
    assert_equal 2, testimonials.current_page
    assert_equal 3, testimonials.total_pages
    assert_equal 10, testimonials.limit_value
    assert_equal 25, testimonials.total_count
  end

  test "searches correctly" do
    mentor = create :user
    student = create :user, handle: "fred"
    create(:mentor_testimonial, mentor:)
    create(:mentor_testimonial, :unrevealed, mentor:, student:)
    fred = create(:mentor_testimonial, :revealed, mentor:, student:)
    foobar = create :mentor_testimonial, :revealed, mentor:, content: "foobar"

    assert_equal [foobar, fred], Mentor::Testimonial::Retrieve.(mentor:, criteria: "f")
    assert_equal [fred], Mentor::Testimonial::Retrieve.(mentor:, criteria: "fr")
    assert_equal [foobar], Mentor::Testimonial::Retrieve.(mentor:, criteria: "fo")
  end
end
