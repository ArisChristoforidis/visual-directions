from firebase_functions import https_fn
from firebase_admin import initialize_app

from datetime import datetime
import os
import requests
import googlemaps
import html2text
import polyline
from math import sin, cos, atan2, pi

import vertexai
from vertexai.preview.generative_models import GenerativeModel, Part, Image
import vertexai.preview.generative_models as generative_models
from google.cloud import aiplatform

PROJECT_NAME=os.getenv("PROJECT_NAME")
PROJECT_LOCATION=os.getenv("PROJECT_LOCATION")
GEMINI_MODEL_NAME=os.getenv("GEMINI_MODEL_NAME")
DIRECTIONS_API_KEY=os.getenv("DIRECTIONS_API_KEY")

h = html2text.HTML2Text()
h.ignore_emphasis = True
h.single_line_break = True

initialize_app()
vertexai.init(project=PROJECT_NAME, location=PROJECT_LOCATION)

def generate_directions(directions, image):
    """
    Generates new directions at a given point based on the visual points of reference
    of the street view image.

    Args:
        directions (str): The old directions as provided by Google Maps.
        image (bytes): The street view image that corresponds to the point where 
        the current directions must be executed.
    
    Returns:
        new_directions (str): The new directions based on the visual points of 
        reference of the street view image.
    """
    print('generate_directions started')
    model = GenerativeModel(GEMINI_MODEL_NAME)
    prompt = f"""
    You are given a street view image and a set of navigation directions corresponding
    to the scene in the image. Augment the navigation direction by incorporating static
    points of reference from the image to the instructions that work as visual aids for 
    the driver. Try to favor elements that stand out due to their color. Avoid using 
    sign names unless they are clearly legible. Suitable points of reference include:
    Landmarks with distinct architecture: Iconic or historic buildings or prominent towers, unique skyscrapers.
    Major intersections with prominent signage: Points where multiple roads meet, marked by large street signs, traffic lights.
    Large shopping centers or malls: Retail complexes with visible signage, expansive parking lots.
    Gas stations or convenience stores: Well-known shops, easily recognizable due to signage, fuel pumps.
    Hotel chains: Well-known brands with large signs, often near tourist spots.
    Fast food chains or drive-thrus: Popular restaurants with bright signage, drive-thru lanes.
    Highway exits or entrances: Ramps with large signs, exit numbers.
    Car dealerships: Showrooms with banners, along major roads.
    Bridges or overpasses: Structures spanning water, serving as landmarks.
    Parks or squares: Green spaces or open areas that serve as central points within neighborhoods or districts.
    Water bodies: Rivers, lakes, or oceans that provide natural landmarks and orientation points, especially in coastal cities.
    Tall communication towers or antennas: Radio towers visible from afar, guiding orientation.
    The navigation directions given are the following: {directions}
    
    Keep the responses brief rather than conversational.
    """
    gemini_safety_settings = {
        generative_models.HarmCategory.HARM_CATEGORY_HATE_SPEECH: generative_models.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        generative_models.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: generative_models.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        generative_models.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: generative_models.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        generative_models.HarmCategory.HARM_CATEGORY_HARASSMENT: generative_models.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
    }
    gemini_config = {
        "max_output_tokens": 2048,
        "temperature": 0.4,
        "top_p": 1,
        "top_k": 32
    }
    image = Image.from_bytes(image)
    response = model.generate_content(
        contents=[prompt, image, directions],
        generation_config=gemini_config,
        safety_settings=gemini_safety_settings,
        stream=False
    )
    print('generate_directions finished')
    return response.text

def get_streetview_image(location, heading):
    """
    Gets the static street view image at the given location.

    Args:
        location (tuple): The position (coordinate pair) of the street view.
        heading (float): The heading for the street view image.
    
    Returns:
        image (bytes): The static street view image with the given heading at the requested location.
    """
    print('get_streetview_image started')
    META_URL = "https://maps.googleapis.com/maps/api/streetview/metadata?"
    BASE_URL = "https://maps.googleapis.com/maps/api/streetview?"
    meta_params = {
        'location': ','.join(list(map(str, location))),
        'key': DIRECTIONS_API_KEY
    }
    params = {
        'location': ','.join(list(map(str, location))),
        'heading': heading,
        'fov': 120,
        'size': '640x300',
        'key': DIRECTIONS_API_KEY,
    }

    meta_response = requests.get(META_URL, meta_params)
    print('get_streetview_image almost done')
    if meta_response.ok:
        response = requests.get(BASE_URL, params)
        print('get_streetview_image done')
        return response.content

def calculate_heading(c1, c2):
    """
    Calculates the heading from two coordinate pairs.

    Args:
        c1 (tuple): The first coordinate pair.
        c2 (tuple): The second coordinate pair.
    
    Returns:
        heading (float): The heading between the first and the second point.
    """
    print('calculate_heading started')
    lat_1, lon_1 = c1
    lat_2, lon_2 = c2
    y = sin(lon_2 - lon_1) * cos(lat_2)
    x = cos(lat_1) * sin(lat_2) - sin(lat_1) * cos(lat_2) * cos(lon_2-lon_1)
    theta = atan2(y, x)
    heading = (theta * 180 / pi + 360) % 360
    print('calculate_heading finished')
    return heading

@https_fn.on_call()
def get_directions(req: https_fn.CallableRequest):
    """
    Gets the directions between two points using Gemini.

    Args:
        origin (str): The starting location.
        destination (str): The destination.
    
    Returns:
        response (dict): The directions for the given route. The navigation directions
        contain the following fields:
            - gmaps_directions (str): The navigation directions as given by the 
            google maps API.
            - gemini_directions (str): The navigation directions augmented by 
            Gemini in order to include visual points of reference.
            - coords (tuple): The coordinates that correspond to each navigation 
            instruction.
            - heading: The heading at each navigation instruction.
    """
    print('get_directions entered')
    origin = req.data["origin"]
    destination = req.data["destination"]
    print('get_directions read values from params')
    print(f"origin: {origin} {type(origin)} ")
    print(f"destination: {destination} {type(destination)} ")
    now = datetime.now()
    gmaps = googlemaps.Client(key=DIRECTIONS_API_KEY)
    directions_result = gmaps.directions(origin, destination, mode="driving", departure_time=now)[0]['legs'][0]['steps']
    print(directions_result)
    response = {}
    for idx, directions_data in enumerate(directions_result):
        gmaps_directions = h.handle(directions_data["html_instructions"]).rstrip().lstrip()
        gmaps_directions = gmaps_directions.replace("\n", "")
        # We use the last two points of the polyline of the current navigation directions
        # to calculate the heading in order to rotate the street view image to the 
        # correct 
        polyline_obj = polyline.decode(directions_data["polyline"]["points"])
        if idx == 0:
            start, end = polyline_obj[:2]

        heading = calculate_heading(start, end)
        # Get the image if it is available. If not, we cannot use Gemini so we
        # fall back to the default Google Maps directions.
        image = get_streetview_image(start, heading)
        if image == None:
            gemini_directions = gmaps_directions
        else:
            gemini_directions = generate_directions(gmaps_directions, image)
        response[idx+1] = {
            'gmaps_directions': gmaps_directions,
            'gemini_directions': gemini_directions,
            'coords': start,
            'heading': heading,
        }
        start, end = polyline_obj[-2:]

    return response
