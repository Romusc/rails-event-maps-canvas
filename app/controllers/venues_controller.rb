class VenuesController < ApplicationController
  # eb refers to eventbrite

  def new
  end

  def create_all
    eb_venue_ids(params[:city], params[:subcategory]).each do |venue_id|
      if Venue.find_by(eb_id: venue_id).nil?
        d = eb_venue_details(venue_id)
        Venue.create!(name: d[:name], latitude: d[:latitude], longitude: d[:longitude],
                      city: d[:city], address: d[:address], eb_id: venue_id)
      end
    end
    redirect_to controller: 'events', action: 'create_all_events', city: params[:city], subcategory: params[:subcategory]
  end

  def index
    @venues = Venue.all
  end



  def destroy
  end

  def create
    redirect_to venues_path
  end

  private

  def venue_params
    params.require(:venue).permit(:name, :address, :city, :subcategory, :artist, :latitude, :longitude)
  end

  # CONSTANTS ARE DEFINED IN 'config/initializers/my_constants'

  # THIS METHODS RETURNS A LIST OF POSSIBLE EVENTBRITE SUBCATEGORIES:
  def subcategories_and_ids_list
    url_no_page = "#{SUBCATEGORIES_URL}?#{TOKEN_PREFIX}#{OAUTH_TOKEN}&#{PAGE_PREFIX}"
    subcategory_names_and_ids = []
    (1..4).each do |i|
      url = url_no_page + "#{i}"
      subcategories = JSON.parse(open(url).read)
      subcategories["subcategories"].each do|subcategory|
        subcategory_names_and_ids << [subcategory["name"], subcategory["id"]]
      end
    end
    subcategory_names_and_ids.sort!
  end

  # THIS METHOD RETURNS THE UNIQUE EVENTBRITE VENUES ASSOCIATED WITH
  # THE EVENTS HAPPENING IN THIS CITY AND WITH THAT SUBCATEGORY:

  def eb_venue_ids(city, subcategory)
    subcategory_and_id = subcategories_and_ids_list.select { |pair| pair[0] == subcategory }
    url_no_page = "#{EVENTS_URL}#{LOCATION_PREFIX}" + city + "&#{SUBCATEGORY_PREFIX}" + subcategory_and_id[0][1] + "&#{TOKEN_PREFIX}#{OAUTH_TOKEN}" + "&#{PAGE_PREFIX}"
    venue_ids = []
    (1..10).each do |i|
      url = url_no_page + "#{i}"
      events = JSON.parse(open(url).read)
      events["events"].each do|event|
        venue_ids << event["venue_id"]
      end
    end
    venue_ids.uniq.sort!
  end

  def eb_venue_details(venue_id)
    url = "#{VENUES_URL}#{venue_id}?#{TOKEN_PREFIX}#{OAUTH_TOKEN}"
    details = JSON.parse(open(url).read)
    eb_venue_details = {}
    eb_venue_details[:name] = details["name"]
    eb_venue_details[:latitude] = details["address"]["latitude"]
    eb_venue_details[:longitude] = details["address"]["longitude"]
    eb_venue_details[:address] = details["address"]["address_1"]
    eb_venue_details[:city] = details["address"]["city"]
    eb_venue_details
  end
  # THESE REQUIRE ARE SUPERFLUOUS, KEEPING THEM HERE UNTIL I UNDERSTAND WHY:
  # require 'open-uri'
  # require 'json'
  # require 'yaml'
end
