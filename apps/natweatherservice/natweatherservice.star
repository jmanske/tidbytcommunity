"""
Applet: NatWeatherService
Summary: Weather.gov API forecasts
Description: Displays forecast information using the national weather service API.
Author: Jake Manske
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("time.star", "time")
load("encoding/json.star", "json")
load("animation.star", "animation")

DEFAULT_WHO = "world"
STATION_CACHE_SECONDS = 86400
GRID_FORECAST_URL = "https://api.weather.gov/points/{},{}"
MY_LOC = """{
    "lat": "43.044170",
    "lng": "-89.549410",
    "description": "Verona, WI, USA",
	"locality": "Verona",
	"place_id": "ChIJCSF8lBZEwokRhngABHRcdoI",
	"timezone": "America/Chicago"
}"""
TEMP_FONT = "10x20"
DESC_COLOR = "#949494"
DESC_FONT = "CG-pixel-4x5-mono"

OPTIONS = [ "Overnight", "Today", "Tonight", "This Afternoon" ]

def main(config):
    loc = json.decode(config.str("location") or MY_LOC)

    info = get_today_forecast(loc)

    return render.Root(
        child = render.Row(
            main_align = "space_between",
            cross_align = "end",
            expanded = True,
            children = [
                render_icon(info.Icon),
                render.Column(
                    cross_align = "end",
                    children = [
                        render.Padding(
                            pad = (0,-3,0,0),
                            child = render.Text(
                                content = info.BigTemp.Value,
                                font = TEMP_FONT,
                                color = info.BigTemp.Color
                            ),
                        ),
                        render.Text(
                            content = info.LittleTemp.Value if info.LittleTemp != None else "0",
                            color = info.LittleTemp.Color if info.LittleTemp != None else "#000000"
                        ),
                        render.Text(
                            content = info.Description,
                            font = DESC_FONT,
                            color = DESC_COLOR
                        )
                    ]
                )
            ]
        )
    )

def render_icon(icon):
    icon_query_params = {
        "size": "small"
    }
    return render.Image(
        src = http.get(icon, params = icon_query_params, ttl_seconds = STATION_CACHE_SECONDS).body(),
        width = 32
    )

def http_get_urls(loc):
    url = GRID_FORECAST_URL.format(loc.get("lat"), loc.get("lng"))

    response = http.get(url, ttl_seconds = STATION_CACHE_SECONDS)

    return response.json().get("properties")

def http_get_forecast(properties):
    url = properties.get("forecast")
    headers = {
        "feature-flags": "forecast_temperature_qv",
    }
    response = http.get(url, headers = headers, ttl_seconds = 30)

    return response.json()

def get_today_forecast(loc):
    properties = http_get_urls(loc)

    info = http_get_forecast(properties)
    high = None
    low = None
    icon = None
    overnight = False
    number = 0
    short_forecast = ""
    for period in info.get("properties").get("periods"):
        # increase the counter
        number += 1
        name = period.get("name")
        end_time = time.parse_time(period.get("endTime"))

        # the entries in the array are 12-hour chunks that go from 6AM to 6PM
        # if the first entry in the array has an end time of "6"
        # it means that the first entry is a "tonight" or "overnight" entry
        if number == 1 and end_time.hour == 6:
            continue
            icon = get_icon(period)
            overnight = True
            high = get_temp(period)
            short_forecast = period.get("shortForecast")
            continue

        # otherwise get today and tonight
        # today will have the high
        # tonight will have the low
        if end_time.hour == 18:
            high = get_temp(period)
            icon = get_icon(period)
            short_forecast = period.get("shortForecast")
            continue
        else:
            low = get_temp(period)
            if icon == None:
                icon = get_icon(period)
        if high != None and low != None:
            break        
    return struct(BigTemp = high, LittleTemp = low, Icon = icon, IsOvernight = overnight, Description = short_forecast)

def get_icon(period):
    return period.get("icon").split("?")[0].split(",")[0]

def get_temp(period):
    # convert value to fahrenheit
    value = int(period.get("temperature").get("value") * 9 / 5.0 + 32)
    # get a color based on the value
    color = "#000000"
    if value < 10:
        color = "#4B0082"
    elif value < 55:
        color = "#0000FF"
    elif value < 80:
        color = "#FF7F00"
    else:
        color = "#FF0000"
    return struct(Value = str(value), Color = color)



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
