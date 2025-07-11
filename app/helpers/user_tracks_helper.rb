module UserTracksHelper
  def user_track_completed_percentage_text(user_track)
    prefix = "tracks.show.summary_article.user_track_completed_percentage_text"
    case user_track.completed_percentage
    when 0...10
      t("#{prefix}.range_0_10")
    when 10...20
      t("#{prefix}.range_10_20")
    when 20...30
      t("#{prefix}.range_20_30")
    when 30...40
      t("#{prefix}.range_30_40")
    when 40...50
      t("#{prefix}.range_40_50")
    when 50...60
      t("#{prefix}.range_50_60")
    when 60...70
      t("#{prefix}.range_60_70")
    when 70...80
      t("#{prefix}.range_70_80")
    when 80...90
      t("#{prefix}.range_80_90")
    when 90...100
      t("#{prefix}.range_90_100")
    else
      t("#{prefix}.invalid_percentage")
    end
  end
end
