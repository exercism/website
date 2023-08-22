class AddNumAwardeesToTrackTrophies < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :track_trophies, :num_awardees, :mediumint, default: 0, null: false
  end
end
