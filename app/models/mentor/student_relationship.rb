class Mentor::StudentRelationship < ApplicationRecord
  self.table_name = "mentor_student_relationships"

  belongs_to :mentor, class_name: "User"
  belongs_to :student, class_name: "User"
end
