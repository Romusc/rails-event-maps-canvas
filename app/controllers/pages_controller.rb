class PagesController < ApplicationController
  def home
    @venue = Venue.new
    @event = Event.new
    subs = []
    subcategories_and_ids_list.each do |hash|
      subs << hash[:name]
    end
    @subcategories = subs.uniq.sort!
  end

  private

  # CONSTANTS ARE DEFINED IN 'config/initializers/my_constants'

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
