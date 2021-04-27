class Mentor::RequestLock < ApplicationRecord
  belongs_to :request
  belongs_to :locked_by, class_name: "User"
end
