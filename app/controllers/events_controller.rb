class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.all
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

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update

  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy

  end

  private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:name, :address, :city, :subcategory, :artist, :latitude, :longitude)
    end

    # def event_names_list(city, subcategory)
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
    #   return event_names_and_venue_ids
    # end

    def event_names_list(city, subcategory)
      subcategory_and_id = subcategories_and_ids_list.select { |pair| pair[0].downcase == subcategory }
      url_no_page = "#{EVENTS_URL}#{LOCATION_PREFIX}" + city + "&#{SUBCATEGORY_PREFIX}" + subcategory_and_id[0][1] + "&#{TOKEN_PREFIX}#{OAUTH_TOKEN}" + "&#{PAGE_PREFIX}"
      event_names_and_venue_ids = []
      (1..10).each do |i|
        url = url_no_page + "#{i}"
        events = JSON.parse(open(url).read)
        events["events"].each do|event|
          event_names_and_venue_ids << {name: event["name"]["text"], venue_id: event["venue_id"]}
        end
      end
      return event_names_and_venue_ids
    end

    def get_address_from_id(venue_id)
      url = "#{VENUE_URL}#{venue_id}/?#{TOKEN_PREFIX}#{OAUTH_TOKEN}"
      details = JSON.parse(open(url).read)
      address = {address_1: details["address"]["address_1"], address_2: details["address"]["address_2"], city: details["address"]["city"],
        latitude: details["address"]["latitude"], longitude: details["address"]["longitude"]}
      address
    end

end
