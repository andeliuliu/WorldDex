"""Welcome to Reflex!."""
import reflex as rx

from worlddex.state import State
from worlddex.pages.dashboard import dashboard
import requests as requests


color = "rgb(107,99,246)"

def index():
    """The main view."""
    return rx.vstack(
        rx.text(State.username),
        rx.box(
            rx.button(
                rx.link('Login', href='/dashboard')
            )
        )
    )

images = [1, 2, 3, 4, 5, 6, 7]
def small_box(image):
    return rx.box(image, height="75px",width="100%",bg="green")

def dashboard():
    """The dashboard page.

    Returns:
        The UI for the dashboard page.
    """
    return rx.hstack(
        rx.vstack(
            rx.box(
                "full size image",
                margin_top="100px",
                border_width="thin",
                border_color="green",
                width="85%",
                height="750px",
            ),
            rx.flex(
                rx.text(
                    "location"
                ),
                rx.spacer(),
                rx.text(
                    "time"
                ),
                margin_top="10px",
                border_width="thin",
                border_color="green",
                width="85%",
                height="35px",
            ),
            rx.box(
                "caption",
                margin_top="20px",
                border_width="thin",
                border_color="green",
                width="85%",
                height="150px",
            ),
            "Main Image Page",
            border_width="thin",
            border_color="green",
            width="85%",
            height="1120px",
        ),
        # rx.vstack(
        #     width="10px",
        #     height="1120px",
        #     bg="black",
        # ),
        rx.vstack(
            rx.box(
                rx.text(
                    "Other Collectables!",
                    font_size='2em',
                ),
                margin_top="85px",
            ),
            rx.box(
                rx.responsive_grid(
                    rx.foreach(images, lambda image: small_box(image)),
                    columns=[3],
                    spacing="4",
                ),
                margin_top="100px",
                border_width="thin",
                border_color="green",
                width="85%",
                height="650px",
            ),
            "Library of other images",
            border_width="thin",
            border_color="green",
            width="40%",
            height="1120px",
            
        ),
        margin="auto",
        width="80%",
        height="1120px",
        border_width="thick",
        border_color="green",
    )
    

# Add state and page to the app.
app = rx.App()
app.add_page(index)
app.add_page(dashboard, route='/dashboard')
app.compile() 