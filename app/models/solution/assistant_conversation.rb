class Solution::AssistantConversation < ApplicationRecord
  belongs_to :solution
  belongs_to :user
end
