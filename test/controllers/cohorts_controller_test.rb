require "test_helper"

class CohortsControllerTest < ActionDispatch::IntegrationTest
  ########
  # Show #
  ########
  test "show: shows for known cohort" do
    create :cohort, slug: 'gohort'

    get cohort_path('gohort')

    assert_template "cohorts/show"
  end

  test "show: 404s for unknown cohort" do
    get cohort_path('unknown')

    assert_rendered_404
  end

  ########
  # Join #
  ########
  test "join: redirects to show page" do
    sign_in!
    create :cohort, slug: 'gohort'

    post join_cohort_path('gohort'), params: { introduction: 'Hi!' }, headers: @headers, as: :json

    assert_redirected_to cohort_path('gohort', anchor: 'register')
  end

  test "join: redirects to show page if current user had already joined" do
    sign_in!
    cohort = create :cohort, slug: 'gohort'
    create(:cohort_membership, user: @current_user, cohort:)

    post join_cohort_path('gohort'), params: { introduction: 'Hi!' }, headers: @headers, as: :json

    assert_redirected_to cohort_path('gohort', anchor: 'register')
  end

  test "join: creates membership if current user had not joined" do
    sign_in!
    create :cohort, slug: 'gohort'

    post join_cohort_path('gohort'), params: { introduction: 'Hi!' }, headers: @headers, as: :json

    membership = CohortMembership.find_by(user: @current_user, cohort: Cohort.find_by(slug: 'gohort'))
    assert 'Hi!', membership.introduction
  end

  test "join: 404s for unknown cohort" do
    sign_in!

    post join_cohort_path('unknown'), params: { introduction: 'Hi!' }, headers: @headers, as: :json

    assert_rendered_404
  end
end
