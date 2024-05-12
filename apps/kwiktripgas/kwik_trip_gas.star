"""
Applet: Kwik Trip Gas
Summary: Show Kwik Trip Gas Prices
Description: Dispays Kwik Trip gas prices in your area.
Author: Jake Manske
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("encoding/json.star", "json")

DEFAULT_WHO = "world"
DEFAULT_LOCATION = """{
    "lat": "42.991692",
    "lng": "-89.529877",
    "locality": "Verona, WI"
}"""

KWIK_TRIP_URL = "https://api.kwiktrip.com/api/stores/nearby"
KWIK_TRIP_STORE_URL = "https://api.kwiktrip.com/api/location/store/information/{0}"

def main(config):
    store_id = json.decode(config.get("store")).get("value")
    print(store_id)
    response = http.get(url = KWIK_TRIP_STORE_URL.format(store_id), ttl_seconds = 60)
    
    print(response.url)
    who = config.str("who", DEFAULT_WHO)
    message = "Hello, {}!".format(who)
    return render.Root(
        child = render.Text(message),
    )

def get_schema():

    return schema.Schema(
        version = "1",
        fields = [
            schema.LocationBased(
                id = "store",
                name = "Kwik Trip",
                desc = "A list of warehouses by location",
                icon = "locationDot",
                handler = get_stations,
            )
        ],
    )

def get_stations(location):
    loc = json.decode(location)
    query_params = {
        "latitude": str(loc.get("lat")),
        "longitude": str(loc.get("lng")),
        "limit": "20" # 1-255
    }
    response = http.get(url = KWIK_TRIP_URL, params = query_params, ttl_seconds = 60)

    stores = response.json().get("stores")
   
    return [
        schema.Option(
            display = store.get("name"),
            value = str(int(store.get("id"))),
        )
        for store in stores
    ]