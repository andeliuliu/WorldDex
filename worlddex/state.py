import httpx
import reflex as rx
from typing import List, Dict, Any
from datetime import datetime


def convert_date_format(date_str: str) -> str:
    # Parse the string into a datetime object
    dt = datetime.strptime(date_str, "%Y-%m-%dT%H:%M:%S.%fZ")
    
    # Convert datetime object to desired format
    formatted_date = dt.strftime("%B %d, %Y")
    
    return formatted_date

class ImageState(rx.State):
    img: List[Dict[str, Any]] = []
    currentImage: str = None
    currentLocation: str = None
    currentTime: str = None
    currentCaption: str = None

    username: str 
    password: str
    email: str

    isCreatingAccount: bool = False

    error: str = "invalid username or password"

    def fetch_data(self):
        url = 'https://worlddex.ngrok.app/images'
        params = {'user_id': self.username}
        print("fetching...")

        with httpx.Client() as client:  # using synchronous Client
            response = client.get(url, params=params)

        if response.status_code == 200:
            data = response.json()
            if 'imagePaths' in data:
                self.img = []
                for item in data['imagePaths']:
                    image_obj = {
                        "date_added": item['date_added'],
                        "location_taken": item['location_taken'],
                        "image": self.get_data_uri_from_base64(item['image']),
                        "details": item['details']
                    }
                    self.img.append(image_obj)

                self.currentImage = (self.img[0]['image']) if self.img else None
                self.currentCaption = (self.img[0]['details']) if self.img else None
                self.currentLocation = (self.img[0]['location_taken']) if self.img else None
                self.currentTime = convert_date_format((self.img[0]['date_added']))if self.img else None

                print("finished requesting")
        else:
            print('Failed.')
            print('Status Code:', response.status_code)
            print('Response:', response.text)

    def get_data_uri_from_base64(self, b64_string):
        return f"data:image/jpeg;base64,{b64_string}"

    def update_current_image(self, image_obj):
        print("clicked")
        self.currentImage = image_obj['image']
        self.currentCaption = image_obj['details']
        self.currentLocation = image_obj['location_taken']
        self.currentTime = convert_date_format(image_obj['date_added'])
        print("after click")

    def setUsername(self, text: str):
        self.username = text
        print(self.username)

    def setPassword(self, text: str):
        self.password = text
        print(self.password)

    def setEmail(self, text: str):
        self.email = text
        print(self.email)

    def newUser(self):
        body = {'user_id': self.username, 'user_password': self.password, 'email' : self.email}
        url = 'https://worlddex.ngrok.app/signup'

        with httpx.Client() as client:  # using synchronous Client
            response = client.post(url, json=body)

        if response.status_code == 200:
            self.fetch_data()
            print("SUCESS!")
        else:
            print(self.error)
    
    def login(self):
        self.fetch_data()

