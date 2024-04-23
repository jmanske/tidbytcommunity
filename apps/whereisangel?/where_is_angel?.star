"""
Applet: Where Is Angel?
Summary: Where is Angel Hernandez
Description: Shows you where Angel Hernandez is right now.
Author: Jake Manske
"""

load("render.star", "render")
load("schema.star", "schema")
load("encoding/base64.star", "base64")

FONT = "CG-pixel-4x5-mono"
DEFAULT_WHO = "world"
GLOBE = base64.decode("""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""")
BASEBALL = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAIKADAAQAAAABAAAAIAAAAACshmLzAAAEyElEQVRYCe1X3U8cVRT/zcwOM8v3tkqxJI2xUrcsxAff/EixIY3GUB8UGlrS0A9YUNLGF40aK+Abb8Ym8mH6mWiW9tHEaGKgjX+CfMTUmBhZaqPQAi0fOzvjORfusDs7A9MnffA+7L1zz7m/87vnnnvPWeBfbsrj2r811u84AYsaWz99bLxQCybIKNtUFAUH6+IB5oGpyWlXFpbMjgTGUwNOoj7fqBl71jUkB6sLd+RQ9NNTMzjUcmFH/ECF26l+xybpc7TjiAqYsQOugdKKancsB8sP7oqhAxWr8+wJFTM/T0PNOnj5eF+gHV/BeKrPqf3iJ2hQoAx3oph2XFb5lLS1Q29j6f6fYI+sJ0fgUMTcOfcKXj3mT4L2lt/4vBP1dTCHu11BeOO8RM0ja4wkkUg0QMaRC7o5yCNw68aAU5c4KERFsWeIvY0M7eL3I+3edcHfFKi/HTkhdp+Fg+iuWoreLBjXj0QeAYnKQabChj6chEYuNIe6AMtXVS7Z6i0gOpQU3yXkRY4XGbR8i7zNRWV24orZHEY2SiprUEzs+dJnukcx13zSu9b3e/b1dljktRVTQVFsv9BhPBAu43u94BLIZrPIYg3m7lphnFdaZFwd7YC6vAbt2ruwIxGaCHqGAEfXEfn6HPQVC6WfnyTyGzvmzTAu41sWkclpGo+ZVX1DgqI9jiKjFBHdECpGtBSOEoUdIy9cSNHyv1FS9wLHmW+7lxqB8vFNKF1NKG54EeWxrZvjkAe0okrsrojgjcb6vis3JvoZpADKiJYVgD95/LSYqzpxBhQUBXI5saflLFZtC1Vtp+SU25vF5e44d1BAIFcox+mjZJhauvk0MkowAZZD1/BHc4fQD/MTikDx1QEYTYdhfvUhdEcVj4sXfH5hCY8GT2HtiT0wLnaSOP+svfryOxSBhaPnoUY0LL39Ea3LuUqaCUQ4XhTsipWhKHkR+r05KN/MwCitkja27UMRMK/1QicCzkgPgdkiKwrU7CpdlTUabhyLcbUXBieQ1gNYW/5rW8NSGIqA030JD7/9Hub5KxS2OR6QKJt9lt4Lfv3We0Y9kuDPAgKLC+kCbX2oUwBrlJiydsDZ0isX+fIs2AHcexsnKL/mboffAk5CRuV+N5ksz6fx8NgHsDa1an647oexNUcBunCoDY9MlTIpUJ2jv3R/jjLkL5iiOqGxZSsz5nmAUyc3VubmkLs1ygfcjOF3RL/tj2Jj/XqPeCw5j0icDeNcsJC5zddR4rge4AnOhvxey+Sx2Pq+0Mtk1vH0eEqu2bFPN7VD0SOw6XkvHxsU+lwfcMnmLdXyPCCRZXml0dk7+6pRcqlXikL1+mhSGI9efk9sWOL5Lc7zACtwLHDutrpGENm3F5nZu9j73WW66r5cCzFV0rMymH2tQ8j0GnoPPnkTXCN6d88KBQR4kkk8P0PFyFsJ/hRHEroqokBcejArSjJ+tbmgWRw8g/hLbb62fCfZKJPgAoK9wcEp46KsooZo+19FDjaFrK7M/8oQ4sz5Wh5uCf6/EEhAINCPPBL5zb0kkzvH49yz9gs4rz5/70iAlSbGPnO4rmOPxONxqHzOAW1yclJIcu96gKqYDkUgF+DHm32Oxn4NaH6BFqD6//R/wwP/AFD2nn1Ez5F6AAAAAElFTkSuQmCC""")

def main(config):
    frames = [
        render.Row(
            children = [get_text("where")]
        ),
        render.Row(
            children = [get_text("where"), get_space(5), get_text("in"), get_space(7), get_text("the")]
        ),
        render.Column(
            children = [
                render.Row(
                    children = [get_text("where"), get_space(5),get_text("in"), get_space(7),get_text("the")]
                ),
                render.Box(
                    height = 1, 
                    width = 1
                ),
                render.Row(
                    children = [get_space(19),get_text("world")]
                )
            ]
        ),
        render.Column(
            children = [
                render.Row(
                    children = [get_text("where"), get_space(5),get_text("in"), get_space(7),get_text("the")]
                ),
                render.Box(
                    height = 1, 
                    width = 1
                ),
                render.Row(
                    children = [get_space(19),get_text("world")]
                ),
                render.Row(
                    children = [get_space(26),get_text("is")]
                )
            ]
        ),
        render.Column(
            children = [
                render.Row(
                    children = [get_text("where"), get_space(5),get_text("in"), get_space(7),get_text("the")]
                ),
                render.Box(
                    height = 1, 
                    width = 1
                ),
                render.Row(
                    children = [get_space(19),get_text("world")]
                ),
                render.Row(
                    children = [get_space(26),get_text("is")]
                )
            ]
        ),
        render.Column(
            children = [
                render.Row(
                    children = [get_text("where"), get_space(5),get_text("in"), get_space(7),get_text("the")]
                ),
                render.Box(
                    height = 1, 
                    width = 1
                ),
                render.Row(
                    children = [get_space(19),get_text("world")]
                ),
                render.Row(
                    children = [get_space(26),get_text("is")]
                ),
                render.Row(
                    cross_align = "center",
                    children = [
                        get_space(10),
                        render.WrappedText(
                            linespacing = 1,
                            align = "center",
                            content = "ANGEL HERNANDEZ"
                        )
                    ]
                )
            ]
        ),
        render.Column(
            children = [
                render.Row(
                    children = [get_text("where"), get_space(5),get_text("in"), get_space(7),get_text("the")]
                ),
                render.Box(
                    height = 1, 
                    width = 1
                ),
                render.Row(
                    children = [get_space(19),get_text("world")]
                ),
                render.Row(
                    children = [get_space(26),get_text("is")]
                ),
                render.Row(
                    cross_align = "center",
                    children = [
                        get_space(10),
                        render.WrappedText(
                            linespacing = 1,
                            align = "center",
                            content = "ANGEL HERNANDEZ"
                        )
                    ]
                )
            ]
        ),
        render.Row(
            children = [get_space(15),
                render.Image(
                    src = GLOBE
                )
            ]
        ),
        render.Row(
            children = [get_space(15),
                render.Image(
                    src = GLOBE
                )
            ]
        ), 
        render.Row(
            children = [get_space(15),
                render.Image(
                    src = BASEBALL
                )
            ]
        ), 
        render.Row(
            children = [get_space(15),
                render.Image(
                    src = BASEBALL
                )
            ]
        ), 

    ]
    return render.Root(
        delay = 600,
        show_full_animation = True,
        child = render.Animation(
            children = frames
        ),
    )


def get_text(text):
    return render.Text(
        content = text,
        font = FONT
    )
def get_space(space):
    return render.Box(
        width = space,
        height = 1
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
