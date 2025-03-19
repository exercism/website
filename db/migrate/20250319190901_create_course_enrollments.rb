class CreateCourseEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :course_enrollments do |t|
      t.bigint :user_id, null: true, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :course_slug, null: false
      t.string :country_code_2, null: true

      t.datetime :paid_at, null: true
      t.string :checkout_session_id, null: true
      t.string :access_code, null: true

      t.timestamps
    end
  end
end
