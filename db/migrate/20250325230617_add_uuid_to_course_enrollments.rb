class AddUuidToCourseEnrollments < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :course_enrollments, :uuid, :string, null: true
    CourseEnrollment.where(uuid: nil).find_each do |enrollment|
      enrollment.update!(uuid: SecureRandom.uuid)
    end
    change_column_null :course_enrollments, :uuid, false
    add_index :course_enrollments, :uuid, unique: true
  end
end
