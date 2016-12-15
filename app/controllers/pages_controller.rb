class PagesController < ApplicationController
  def home
    @venue = Venue.new
    @event = Event.new
    @subcategories = []
    subcategories_and_ids_list.each do |hash|
      @subcategories << hash[:name]
    end
    @subcategories.uniq.sort!
  end

  private

    require 'open-uri'
    require 'json'
    require 'yaml'

    KEYS = YAML.load(File.open("./config/application.yml", 'r'))
    OAUTH_TOKEN = KEYS['keys']['OAUTH_TOKEN']
    API_KEY = KEYS['keys']['API_KEY']

    SUBCATEGORIES_URL = 'https://www.eventbriteapi.com/v3/subcategories/'
    EVENTS_URL = 'https://www.eventbriteapi.com/v3/events/search/?'
    SPECIFIC_EVENT_URL = 'https://www.eventbriteapi.com/v3/events/'

    LOCATION_PREFIX = 'location.address='
    PAGE_PREFIX = 'page='
    TOKEN_PREFIX = 'token='
    SUBCATEGORY_PREFIX = 'subcategories='

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

end
