json.extract! event, :id, :name, :address, :city, :subcategory, :artist, :latitude, :longitude, :created_at, :updated_at
json.url event_url(event, format: :json)