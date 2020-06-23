class PagesController < ApplicationController
  def index
    IterationsChannel.broadcast_to Solution.first, {foo: 'bar', time: Time.now.to_f}
  end
end
