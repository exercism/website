class Localization::Controller < ApplicationController
  def index
    @glossary_entries = AssembleLocalizationGlossaryEntries.(current_user, params)[:results]
    @glossary_entries_params = params.permit(:criteria, :status, :page)
  end

  def show
    glossary_entry = Localization::GlossaryEntry.find_by!(uuid: params[:id])

    @glossary_entry = SerializeLocalizationGlossaryEntry.(glossary_entry, current_user)
  end
end
