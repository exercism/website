module ReactComponents
  class Bootcamp::DrawingPage < ReactComponent
    initialize_with :drawing

    def to_s
      super(id, data)
    end

    def id = "bootcamp-drawing-page"

    def data
      {
        drawing: {
          uuid: drawing.uuid,
          title: drawing.title,
          background_slug: drawing.background_slug
        },
        code: {
          code: drawing.code,
          stored_at: drawing.updated_at
        },
        backgrounds: BACKGROUNDS,
        links: {
          update_code: Exercism::Routes.api_bootcamp_drawing_url(drawing),
          drawings_index: Exercism::Routes.bootcamp_project_path(:drawing)
        }
      }
    end
  end

  BACKGROUNDS = [
    {
      slug: "none",
      title: "No background",
      image_url: nil
    },
    {
      slug: "room",
      title: "A room to decorate",
      image_url: "..."
    }
  ].freeze
end
