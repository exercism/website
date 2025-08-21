class Bootcamp::Admin::SettingsController < Bootcamp::Admin::BaseController
  # GET /settings
  def show; end

  # POST /settings/increment
  def increment_level
    Bootcamp::Settings.connection.execute("UPDATE settings SET level_idx = level_idx + 1")

    redirect_to admin_settings_path, notice: "Level incremented successfully!"
  end
end
