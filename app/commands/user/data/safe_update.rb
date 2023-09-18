class User::Data::SafeUpdate
  include Mandate

  def initialize(user, &block)
    @user = user
    @block = block
  end

  def call
    User::Data.transaction do
      data = User::Data.lock(true).find(user.data.id)
      block.(data)
      data.save!
    end
  end

  private
  attr_reader :user, :block
end
