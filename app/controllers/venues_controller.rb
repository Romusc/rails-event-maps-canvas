class VenuesController < ApplicationController
  # eb refers to eventbrite

  def new
  end

  def create_all

    # p 'bijour'
    # p eb_venue_ids(params[:city], params[:subcategory])
    # p 'random'

    eb_venue_ids(params[:city], params[:subcategory]).each do |venue_id|
      if Venue.find_by(eb_id: venue_id).nil?
        d = eb_venue_details(venue_id)
        Venue.create!(name: d[:name], latitude: d[:latitude], longitude: d[:longitude],
                      city: d[:city], address: d[:address], eb_id: venue_id)
      end
    end
    # p eb_venue_details('17248556')
    redirect_to venues_path
  end

  def index
    @venues = Venue.all
  end




  def create
    p "GGG"
    redirect_to root_path
  end

  private

  def venue_params
    params.require(:venue).permit(:name, :address, :city, :subcategory, :artist, :latitude, :longitude)
  end

  def destroy
  end

  # LET'S REQUIRE ALL THE NECESSARY "require":

  require 'open-uri'
  require 'json'
  require 'yaml'

  # LET'S DECLARE THE CONSTANTS HERE SO THAT WE DON'T OVERWHELM THE TOP OF THE SCREEN:

  KEYS = YAML.load(File.open("./config/application.yml", 'r'))
  OAUTH_TOKEN = KEYS['keys']['OAUTH_TOKEN']
  API_KEY = KEYS['keys']['API_KEY']

  SUBCATEGORIES_URL = 'https://www.eventbriteapi.com/v3/subcategories/'
  EVENTS_URL = 'https://www.eventbriteapi.com/v3/events/search/?'
  VENUES_URL = 'https://www.eventbriteapi.com/v3/venues/'

  LOCATION_PREFIX = 'location.address='
  PAGE_PREFIX = 'page='
  TOKEN_PREFIX = 'token='
  SUBCATEGORY_PREFIX = 'subcategories='

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
    subcategory_and_id = subcategories_and_ids_list.select { |pair| pair[0].downcase == subcategory }
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

  # def names_and_venue_ids(city, subcategory)
  #   subcategory_and_id = subcategories_and_ids_list.select { |pair| pair[0].downcase == subcategory }
  #   url_no_page = "#{EVENTS_URL}#{LOCATION_PREFIX}" + city + "&#{SUBCATEGORY_PREFIX}" + subcategory_and_id[0][1] + "&#{TOKEN_PREFIX}#{OAUTH_TOKEN}" + "&#{PAGE_PREFIX}"
  #   event_names_and_venue_ids = []
  #   (1..10).each do |i|
  #     url = url_no_page + "#{i}"
  #     events = JSON.parse(open(url).read)
  #     events["events"].each do|event|
  #       event_names_and_venue_ids << {name: event["name"]["text"], venue_id: event["venue_id"]}
  #     end
  #   end
  #   names_and_venue_ids
  # end

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

end
