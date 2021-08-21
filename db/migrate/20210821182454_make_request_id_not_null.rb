class MakeRequestIdNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :mentor_discussions, :request_id, null: false
  end
end
