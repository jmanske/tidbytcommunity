"""
Applet: NatWeatherService
Summary: Weather.gov API forecasts
Description: Displays forecast information using the national weather service API.
Author: Jake Manske
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")

DEFAULT_WHO = "world"
STATION_CACHE_SECONDS = 86400
GRID_FORECAST_URL = "https://api.weather.gov/points/{},{}"
MY_LOC = {
    "lat": "43.044170",
    "lng": "-89.549410",
    "description": "Verona, WI, USA",
	"locality": "Verona",
	"place_id": "ChIJCSF8lBZEwokRhngABHRcdoI",
	"timezone": "America/Chicago"
}

def main(config):
    loc = config.str("location") or MY_LOC
    loc = MY_LOC
    properties = http_get_urls(loc)

    info = http_get_forecast(properties)
    return render.Root(
        child = render.Image(
            src = http.get(info.get("properties").get("periods")[2].get("icon")).body(),
            width = 32
        )
    )

def http_get_urls(loc):
    url = GRID_FORECAST_URL.format(loc.get("lat"), loc.get("lng"))
    response = http.get(url, ttl_seconds = STATION_CACHE_SECONDS)

    return response.json().get("properties")

def http_get_forecast(properties):
    response = http.get(properties.get("forecast"), ttl_seconds = 30)
    
    return response.json()

    

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Location(
                id = "location",
                name = "Location",
                desc = "Location for which to display the forecast.",
                icon = "locationDot",
            )
        ],
    )
