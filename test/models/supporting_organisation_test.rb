require "test_helper"

class SupportingOrganisationTest < ActiveSupport::TestCase
  test "parses markdown to html on save" do
    supporting_org = build :supporting_organisation, description_markdown: "Hello"

    supporting_org.save

    assert_equal "<p>Hello</p>\n", supporting_org.description_html
  end

  test "scope: featured" do
    supporting_org_1 = create :supporting_organisation, featured: true
    supporting_org_2 = create :supporting_organisation, featured: true
    create :supporting_organisation, featured: false

    assert_equal [supporting_org_1, supporting_org_2], SupportingOrganisation.featured.order(:id)
  end
end
