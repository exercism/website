class User::MigrateToDataRecord
  include Mandate

  initialize_with :user_id

  def call
    fields = User::Data::FIELDS.join(", ")

    User::Data.connection.insert <<~SQL
      INSERT INTO user_data(user_id, #{fields}, created_at, updated_at)
      SELECT users.id, #{fields}, NOW(), NOW()
      FROM USERS
      WHERE users.id = #{user_id}
    SQL
  rescue ActiveRecord::RecordNotUnique
    # This is fine
  end
end
