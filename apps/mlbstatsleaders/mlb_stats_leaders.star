"""
Applet: MLB Stats Leaders
Summary: Show leaders for MLB stats
Description: Displays a leaderboard for a given stat for the current season. Can filter to your favorite team or see leaders league-wide!
Author: Jake Manske
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")

DEFAULT_WHO = "world"
MLB_HEADSHOT_URL = "https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_150/v1/people/{0}/headshot/67/current"
MLB_LEADERS_URL = "https://statsapi.mlb.com/api/v1/stats/leaders"

def main(config):
    response = http.get(MLB_HEADSHOT_URL.format("607067"))
    query_params = {
        "sportId": "1",
        "leaderCategories": "homeRuns",
        "limit": "3",
        "teamId": "158",
        "statGroup": "hitting",
        "hydrate": "hydrations"
    }
    leaders = http.get(MLB_LEADERS_URL, params = query_params, ttl_seconds = 60)
    print(leaders.url)

    # for each leader, add them to the array
    photos = []
    for player in leaders.json().get("leagueLeaders")[0].get("leaders"):
        response = http.get(MLB_HEADSHOT_URL.format(str(int(player.get("person").get("id")))))
        print(response.url)
    return render.Root(
        child = render.Image(
            src = response.body(),
            height = 32
        )
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
