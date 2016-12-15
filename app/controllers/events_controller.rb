class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = []
    @venues = []
    Venue.near(params[:city], 30).select do |venue|
      if venue.events.select {|event| event.subcategory == params[:subcategory]} != []
        @events << (venue.events.select {|event| event.subcategory == params[:subcategory]}).flatten
        @events.flatten!
        @venues << venue
      end
    end
    @hash = Gmaps4rails.build_markers(@venues) do |venue, marker|
      marker.lat venue.latitude
      marker.lng venue.longitude
    end
  end

  def create_all_events
    eb_event_ids(params[:city], params[:subcategory]).each do |event_id|
      if Event.find_by(eb_id: event_id).nil?
        d = eb_event_details(event_id)
        Event.create!(name: d[:name], subcategory: d[:subcategory], venue_id: d[:venue_id],
                      eb_id: d[:eb_id])
      end
    end
    redirect_to controller: 'events', action: 'index', city: params[:city], subcategory: params[:subcategory]
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new(event_params)
  end

  def update
  end

  def destroy
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :address, :city, :subcategory, :artist, :latitude, :longitude)
  end

  # Constants are defined in 'config/initializers/my_constants'

  def subcategories_and_ids_list
    url_no_page = "#{SUBCATEGORIES_URL}?#{TOKEN_PREFIX}#{OAUTH_TOKEN}&#{PAGE_PREFIX}"
    subcategory_names_and_ids = []
    (1..4).each do |i|
      url = url_no_page + "#{i}"
      subcategories = JSON.parse(open(url).read)
      subcategories["subcategories"].each do|subcategory|
        subcategory_names_and_ids << {name: subcategory["name"], id: subcategory["id"]}
      end
    end
    subcategory_names_and_ids
  end

  def eb_event_ids(city, subcategory)
    subcategory_and_id = subcategories_and_ids_list.select { |pair| pair[:name] == subcategory }
    url_no_page = "#{EVENTS_URL}#{LOCATION_PREFIX}" + city + "&#{SUBCATEGORY_PREFIX}" + subcategory_and_id[0][:id] + "&#{TOKEN_PREFIX}#{OAUTH_TOKEN}" + "&#{PAGE_PREFIX}"
    event_ids = []
    (1..10).each do |i|
      url = url_no_page + "#{i}"
      events = JSON.parse(open(url).read)
      events["events"].each do|event|
        event_ids << event["id"]
      end
    end
    event_ids.uniq.sort!
  end

  def eb_event_details(event_id)
    url = "#{SPECIFIC_EVENT_URL}#{event_id}/?#{TOKEN_PREFIX}#{OAUTH_TOKEN}"
    details = JSON.parse(open(url).read)
    p details
    p "THOSE WERE THE EVENT DETAILS"
    eb_event_details = {}
    eb_event_details[:name] = details["name"]["text"]
    eb_event_details[:subcategory] = (subcategories_and_ids_list.detect{|hash| hash[:id] == details["subcategory_id"]})[:name]
    eb_event_details[:venue_id] = Venue.all.find_by(eb_id: details["venue_id"]).id
    eb_event_details[:eb_id] = details["id"]
    eb_event_details
  end
  # require 'open-uri'
  # require 'json'
  # require 'yaml'
end
