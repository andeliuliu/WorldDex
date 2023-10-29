"""Welcome to Reflex!."""
import reflex as rx
from worlddex.state import ImageState
from worlddex.pages.dashboard import dashboard
import requests as requests



def index():
    """The main view."""
    return rx.vstack(
        rx.center(
            rx.image(
                src='AppIcon2.jpg',
                border_radius="80px",
                width="50%",
                height="auto"
            ),
            height="500px",
            width="50%",
            style={"overflow": "hidden"},
            margin_top="100px",
            # border_width="thin",
            # border_color="green",
        ),
        rx.vstack(
            rx.vstack(
                rx.input(
                    placeholder="Username",
                    size="md",
                    bg="white",
                    font_color="#5C4033",
                    value=ImageState.username,
                    on_change=ImageState.setUsername
                ),
                rx.input(
                    placeholder="Password",
                    size="md",
                    bg="white",
                    font_color="#5C4033",
                    value=ImageState.password,
                    on_change=ImageState.setPassword
                ),
                rx.box(
                    rx.button(
                        rx.link('Login', href='/dashboard'),
                        bg="white",
                        on_click=lambda: ImageState.login()
                    ),
                ),
                rx.box(
                    rx.link(
                        "Create an Account",
                        href='/makeAccount',
                    ),
                ),
                margin="50px",
                # border_width="thin",
                # border_color="green",
            ),
        
        ),
        bg="#ece0d1",
        height="1120px"
        
    )

def small_box(image):
    return rx.center(
        
        rx.image(src=(image['image']), style={"max-width": "100%", "max-height": "100%"}),
        on_click=lambda: ImageState.update_current_image(image),
        cursor="pointer",
        height="100px",
        width="100%",
        border_radius="10px",
        bg="white",
        _hover={
        "transform": "scale(1.1)",
        "transition": "transform .2s"
        },
        style={"overflow": "hidden"},
        padding="5px",
        box_shadow="lg"
    )

def makeAccount():
    return rx.vstack(
        rx.center(
            rx.image(
                src='/AppIcon.jpg',
                border_radius="80px",
                width="50%",
                height="auto"
            ),
            height="500px",
            width="50%",
            style={"overflow": "hidden"},
            margin_top="100px",
        ),
        rx.vstack(
            rx.vstack(
                rx.input(
                    placeholder="Enter Username",
                    size="md",
                    bg="white",
                    font_color="#5C4033",
                    value=ImageState.username,
                    on_change=ImageState.setUsername
                ),
                rx.input(
                    placeholder="Enter Password",
                    size="md",
                    bg="white",
                    font_color="#5C4033",
                    value=ImageState.password,
                    on_change=ImageState.setPassword
                ),
                rx.input(
                    placeholder="Enter Email",
                    size="md",
                    bg="white",
                    font_color="#5C4033",
                    value=ImageState.email,
                    on_change=ImageState.setEmail
                ),
                rx.box(
                    rx.button(
                        rx.link('Create', href='/dashboard'),
                        bg="white",
                        on_click=lambda: ImageState.newUser(),
                    ),
                ),
                rx.box(
                    rx.link(
                        "Back to Login",
                        href='/',
                    ),
                ),
                margin="20px",
                # border_width="thin",
                # border_color="green",
            ),
        ),
        bg="#ece0d1",
        height="1120px"
    )


@rx.page(on_load=ImageState.fetch_data())
def dashboard():
    """The dashboard page.

    Returns:
        The UI for the dashboard page.
    """
    return rx.hstack(
        rx.vstack(
            rx.flex(
                rx.text(
                    ImageState.currentLocation,
                    as_='b',
                    font_size="1.5em"
                ),
                rx.spacer(),
                rx.text(
                    ImageState.currentTime,
                    font_size="1.5em",
                    as_='b'
                ),
                margin_top="100px",
                # border_width="thin",
                # border_color="green",
                width="68%",
                height="35px",
            ),
            rx.center(
                rx.image(src=ImageState.currentImage, style={"max-width": "100%", "max-height": "100%"}),
                margin_top="100px",
                border_width="medium",
                border_color="#5C4033",
                border_radius="20px",
                bg="white",
                width="70%",
                height="750px",
                padding="20px"
            ),
            rx.box(
                rx.text(
                    ImageState.currentCaption
                ),
                margin_top="20px",
                # border_width="thin",
                # border_color="green",
                width="68%",
                height="150px",
            ),
            "Main Image Page",
            # border_width="thin",
            # border_color="green",
            width="85%",
            height="1120px",
        ),
        # rx.vstack(
        #     width="10px",
        #     height="1120px",
        #     bg="black",
        # ),
        rx.vstack(
            rx.center(
                rx.text(
                    ImageState.username + "'s WorldDex!",
                    font_family="trebuchet ms",
                    font_size='3em',
                    as_='b'
                ),
                margin_top="85px",
            ),
            rx.box(
                rx.responsive_grid(
                    rx.foreach(ImageState.img, lambda image: small_box(image)),
                    columns=[4],
                    spacing="4",
                ),
                margin_top="100px",
                # border_width="thin",
                # border_color="green",
                width="85%",
                height="650px",
            ),
            "Library of other images",
            # border_width="thin",
            # border_color="green",
            width="70%",
            height="1120px",
            
        ),
        margin_right="25%",
        width="100%",
        height="1120px",
        bg="#ece0d1"
    )
    

# Add state and page to the app.
app = rx.App()
app.add_page(index)
app.add_page(dashboard, route='/dashboard')
app.add_page(makeAccount, route='/makeAccount')
app.compile() 