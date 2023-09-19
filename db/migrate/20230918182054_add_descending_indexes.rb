class AddDescendingIndexes < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :user_notifications, [:user_id, :status, :id], order: {id: :desc} # DONE
    remove_index :user_notifications, :user_id
    remove_index :user_notifications, [:user_id, :status]

    # Reputation tokens
    add_index :user_reputation_tokens, [:user_id, :seen, :id], order: {id: :desc} # DONE
    add_index :user_reputation_tokens, [:user_id, :id], order: {id: :desc} # DONE
    c.add_index :user_reputation_tokens, [:user_id, :type, :id], order: {id: :desc} # DONE
    c.add_index :user_reputation_tokens, [:user_id, :track_id, :id], order: {id: :desc} # DONE
    c.add_index :user_reputation_tokens, [:user_id, :category, :id], order: {id: :desc} # DONE
    c.add_index :user_reputation_tokens, [:user_id, :id], order: {id: :desc} # DONE

    # Community videos
    add_index :community_videos, [:status, :published_at], order: {published_at: :desc}
    add_index :community_videos, [:status, :track_id], :published_at, order: {published_at: :desc}
    add_index :community_videos, [:status, :exercise_id], :published_at, order: {published_at: :desc}
    add_index :community_videos, [:status, :author_id], :published_at, order: {published_at: :desc}
    add_index :community_videos, [:status, :submitted_by_id], :published_at, order: {published_at: :desc}
    add_index :community_videos, [:status, :published_at], :published_at, order: {published_at: :desc}
    remove_index :community_videos, :published_at
    remove_index :community_videos, :track_id
    remove_index :community_videos, :exercise_id
    remove_index :community_videos, :author_id
    remove_index :community_videos, :published_at

    # Reputation Periods - ALL DONE
    add_index :user_reputation_periods, [:period,:category,:about,:track_id,:reputation], order: {reputation: :desc},  name: "search-1-desc"
    add_index :user_reputation_periods, [:period,:category,:about,:reputation], order: {reputation: :desc},  name: "search-2-desc"
    add_index :user_reputation_periods, [:period,:category,:about,:track_id,:user_handle,:reputation], order: {reputation: :desc},  name: "search-3-desc"
    add_index :user_reputation_periods, [:period,:category,:about,:track_id,:reputation,:id], order: {reputation: :desc},  name: "search-5-desc"
  end
end
