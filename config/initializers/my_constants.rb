KEYS = YAML.load(File.open("./config/application.yml", 'r'))
OAUTH_TOKEN = KEYS['keys']['OAUTH_TOKEN']
API_KEY = KEYS['keys']['API_KEY']

SUBCATEGORIES_URL = 'https://www.eventbriteapi.com/v3/subcategories/'
EVENTS_URL = 'https://www.eventbriteapi.com/v3/events/search/?'
SPECIFIC_EVENT_URL = 'https://www.eventbriteapi.com/v3/events/'
VENUES_URL = 'https://www.eventbriteapi.com/v3/venues/'

LOCATION_PREFIX = 'location.address='
PAGE_PREFIX = 'page='
TOKEN_PREFIX = 'token='
SUBCATEGORY_PREFIX = 'subcategories='

