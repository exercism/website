class Localization::GlossaryEntriesController < ApplicationController
  before_action :ensure_translator_locale
  def index
    @glossary_entries = AssembleLocalizationGlossaryEntries.(current_user, params)[:results]
    @glossary_entries_params = params.permit(:criteria, :status, :page)
  end

  def show
    glossary_entry = Localization::GlossaryEntry.find_by!(uuid: params[:id])

    @glossary_entry = SerializeLocalizationGlossaryEntry.(glossary_entry, current_user)
  end

  private
  def ensure_translator_locale
    return if current_user&.translator_locales.present?

    redirect_to new_localization_translator_path
  end
end
