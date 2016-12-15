class PagesController < ApplicationController
  def home
    @venue = Venue.new
    @event = Event.new
  end

end
