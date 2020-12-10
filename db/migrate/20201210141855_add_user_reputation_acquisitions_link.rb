class AddUserReputationAcquisitionsLink < ActiveRecord::Migration[6.1]
  def change
    add_column :user_reputation_acquisitions, :link, :string, null: true
  end
end
