class Bootcamp::PagesController < Bootcamp::BaseController
  def faqs
    @content = Markdown::Parse.(
      File.read(Rails.root / "bootcamp_content/faqs.md"),
      lower_heading_levels_by: 0
    )
  end
end
