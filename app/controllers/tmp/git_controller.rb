class Tmp::GitController < ApplicationController
  def pull
    Git::Repository.new(:v3).update!
  end
end

