"""
Applet: StubHub Low Price
Summary: Show lowest price
Description: Show the lowest price.
Author: Jake Manske
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")

DEFAULT_WHO = "world"
STUBHUB_TOKEN_URL = "https://account.stubhub.com/oauth2/token"

def main(config):
    headers = {
        "Authorization": "fadf3f4f3:ffad3f222",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    params = {
        "grant_type": "client_credentials"
    }
    response = http.get(STUBHUB_TOKEN_URL, headers = headers, params = params)


    print(response)
    who = config.str("who", DEFAULT_WHO)
    message = "Hello, {}!".format(who)
    return render.Root(
        child = render.Text(message),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "who",
                name = "Who?",
                desc = "Who to say hello to.",
                icon = "user",
            ),
        ],
    )
