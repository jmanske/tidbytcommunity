"""
Applet: Mars Rover Photos
Summary: Show images from Mars rover
Description: Displays an image from the Mars rover.
Author: Jake Manske
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")

API_KEY = "h3pwx82jYjVJjNmMNpHEplH9cEWdlmd30jxRlOA9"
NASA_URL = "https://api.nasa.gov/mars-photos/api/v1/rovers/{0}/photos"
DEFAULT_ROVER = "curiosity"
DEFAULT_WHO = "world"

def main(config):
    rover = config.str("rover", DEFAULT_ROVER)
    url = NASA_URL.format(rover)
    query_params = {
        "sol": "1000",
        "api_key": API_KEY
    }

    response = http.get(url, params = query_params)

    print(response.url)

    img_url = response.json().get("photos")[0].get("img_src")
    img = http.get(img_url)
    who = config.str("who", DEFAULT_WHO)
    message = "Hello, {}!".format(who)
    return render.Root(
        child = render.Image(
            src = img.body(),
            width = 64,
            height = 32
        )
    )

def get_schema():
    rover_options = [
        schema.Option(
            display = "Curiosity",
            value = "curiosity",
        ),
        schema.Option(
            display = "Opportunity",
            value = "opportunity",
        ),
        schema.Option(
            display = "Spirit",
            value = "spirit",
        ),
    ]
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "rover",
                name = "Rover",
                desc = "Rover to follow.",
                icon = "baseballBatBall",
                options = rover_options,
                default = DEFAULT_ROVER
            ),
        ],
    )
