class PagesController < ApplicationController
  def home
    @venue = Venue.new
  end

end
