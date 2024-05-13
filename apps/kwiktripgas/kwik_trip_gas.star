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
load("encoding/base64.star", "base64")

DEFAULT_WHO = "world"
DEFAULT_LOCATION = """{
    "lat": "42.991692",
    "lng": "-89.529877",
    "locality": "Verona, WI"
}"""

SMALL_FONT = "CG-pixel-3x5-mono"
KWIK_TRIP_URL = "https://api.kwiktrip.com/api/stores/nearby"
KWIK_TRIP_STORE_URL = "https://api.kwiktrip.com/api/location/store/information/{0}"
LOGO = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAEAAAAALCAYAAADP9otxAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAQKADAAQAAAABAAAACwAAAABpcivoAAAB4klEQVRIDcVUvUoDQRDeTZQU6Sxtk0NQIsQTxAewFQt9BAtfwsKHsPEZLGx9AkFM4eUao+m0sBQiKJp155Ivfo67MWCigTAz3/x+s7tnjfpl9TUHqHHbsqIzJjZw0Wfx0/1iPaYxR4mLX9fSHbZF18NMo6nu8Z92ccIYgMkKUbZ9zKnHdhH7V5JnmMXy52JEYo2B6wUF7SQ99vUPpEejczV4TsngiTU6w+c1tDEHcNghmSXp6JmK/6VnqusPV88ci5jPvl9zgI+eAIhxkSnoBXnUyRRZZb9q8jzTuNOvVE0PhKUX60M7xwyQEtNO0ovRAuAISR4k5BeMY/Sw2DbnMnkh7v8V9sd0Jid1Q7WRS75lxpw1J2L7a7QRXYA17ghJIcmEg351TVtLzcVQnD51xOT15jb0kAQ5XkgojjHkWGf2gRffAEXG+RMsFuPxQwROKvXpI2++b++hTyL7xp4hDjWd2Su3TbeAY8Q1zjbrUkQW8u0jCPJo/luJrXMdZ8s1697vBJOnELsFnCN6O+m+AZO6IBTqMSlWyurpOYr+JPOVzQWOwckwJjoGA67f++rN5eAYEaAk38hQjxA5KaH7ctlYjr/qbguBoWbwiXzMK09sa13nx5rqvEnsceRivhjO/T4AJQvp6Tvxy3MAAAAASUVORK5CYII=""")
AQUA = "00FFFF"
def main(config):

    stores = get_stores_for_processing(DEFAULT_LOCATION)
    
    store_specific_info = []
    for store in stores:
        store_id = str(int(store.get("id")))

        response = http.get(url = KWIK_TRIP_STORE_URL.format(store_id), ttl_seconds = 600)

        store_specific_info.append(response.json())

    sorted_stores = sorted(store_specific_info, order_stores)

    data = sorted_stores[0]
    address = data.get("address").get("address1")
    short_address = ""
    if len(address) > 15:
        i = 0
        for s in address.elems():
            if i >= 16:
                break
            short_address += s
            i+=1
    else:
        short_address = address
    

    regular_price = ""
    premium_price = ""
    for fuel in data.get("fuel"):
        if regular_price != "" and premium_price != "":
            break
        fuel_type = fuel.get("type")
        if fuel_type.find("PREMIUM") > -1:
            premium_price = fuel.get("currentPrice")
            continue
        if fuel_type.find("UNLEADED 87") > -1:
            regular_price = fuel.get("currentPrice")
    

    return render.Root(
        child = render.Column(
            cross_align = "center",
            children = [
                render.Image(
                    src = LOGO  
                ),
                render.WrappedText(
                    align = "center",
                    content = short_address,
                    font = SMALL_FONT,
                    linespacing = 1
                ),
                render.Row(
                    expanded = True,
                    main_align = "space_between",
                    children = [
                        render.Column(
                            children = [
                                render.Text(
                                    content = "REG",
                                    color = AQUA,
                                    font = SMALL_FONT
                                ),
                                render.Text(
                                    content = str(regular_price)
                                )
                            ]
                        ),
                        render.Column(
                            children = [
                                render.Text(
                                    content = "PRE",
                                    color = AQUA,
                                    font = SMALL_FONT
                                ),
                                render.Text(
                                    content = str(premium_price)
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.LocationBased(
                id = "store",
                name = "Kwik Trip",
                desc = "A list of Kwik Trips by location",
                icon = "locationDot",
                handler = get_stores,
            )
        ],
    )

def get_stores(location):
    stores = get_stores_for_processing(location)
   
    return [
        schema.Option(
            display = store.get("name"),
            value = str(int(store.get("id"))),
        )
        for store in stores
    ]

def order_stores(store):
    premium_price = ""
    for fuel in store.get("fuel"):
        if premium_price != "":
            break
        fuel_type = fuel.get("type")
        if fuel_type.find("PREMIUM") > -1:
            premium_price = fuel.get("currentPrice")
            continue
    return premium_price
def get_stores_for_processing(location):
    loc = json.decode(location)
    query_params = {
        "latitude": str(loc.get("lat")),
        "longitude": str(loc.get("lng")),
        "limit": "10" # 1-255
    }
    response = http.get(url = KWIK_TRIP_URL, params = query_params, ttl_seconds = 60)

    stores = response.json().get("stores")

    stores_with_gas = []
    for store in stores:
        properties = store.get("properties")
        for property in properties:
            if property.get("name") == "GAS":
                if property.get("hasProperty"):
                    stores_with_gas.append(store)
                break
   
    return stores_with_gas