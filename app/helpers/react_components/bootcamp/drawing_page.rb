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
          uuid: drawing.uuid
        },
        code: {
          code: drawing.code,
          stored_at: drawing.updated_at
        },
        links: {
          update_code: Exercism::Routes.api_bootcamp_drawing_url(drawing),
          drawings_index: Exercism::Routes.bootcamp_drawings_url(only_path: true)
        }
      }
    end
  end
end
