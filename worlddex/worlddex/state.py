"""Base state for the app."""

import reflex as rx
import requests as requests

class State(rx.State):
    """The app state."""

    # The images to show.
    # img: list[str]
    username: str

    async def fetch_data(self):
        url = 'http://localhost:3000/user'
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            print(data)
            self.username = data[0]["username"]

color = "rgb(107,99,246)"

