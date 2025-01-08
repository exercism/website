module ViewComponents
  class Bootcamp::ConceptWidget < ViewComponent
    initialize_with :concept

    def to_s
      render template: "components/bootcamp/concept_widget", locals: {
        concept:
      }
    end
  end
end
