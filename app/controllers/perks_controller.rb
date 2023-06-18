class PerksController < ApplicationController
  def index
    @perks = Partner::Perk.all
  end
end
