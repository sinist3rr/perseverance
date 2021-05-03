import requests
from random import choice
from flask import Flask, render_template

app = Flask(__name__)


rover_url = 'https://api.nasa.gov/mars-photos/api/v1/rovers/perseverance/photos'
CAM = 'EDL_PUCAM1'
API_KEY = 'rC67gPuZP85lEBlsiS7VhIz2fhMp1YLEmL54EDwe'
CHERRY_PICKS = [
        'https://mars.nasa.gov/mars2020-raw-images/pub/ods/surface/sol/00064/ids/edr/browse/ncam/NLF_0064_0672625687_026ECM_N0032046NCAM00412_01_195J01_1200.jpg',
        'https://mars.nasa.gov/mars2020-raw-images/pub/ods/surface/sol/00062/ids/edr/browse/zcam/ZL0_0062_0672438698_738ECM_N0032046ZCAM08106_110085J01_1200.jpg',
        'https://mars.nasa.gov/mars2020-raw-images/pub/ods/surface/sol/00060/ids/edr/browse/zcam/ZR0_0060_0672265022_087ECM_N0032046ZCAM05029_110085J01_1200.jpg',
        'https://mars.nasa.gov/mars2020-raw-images/pub/ods/surface/sol/00050/ids/edr/browse/zcam/ZR0_0050_0671377559_653ECM_N0031950ZCAM05020_034085J01_1200.jpg',
        'https://mars.nasa.gov/mars2020-raw-images/pub/ods/surface/sol/00050/ids/edr/browse/zcam/ZL0_0050_0671381891_053ECM_N0031950ZCAM08013_063085J01_1200.jpg',
        'https://mars.nasa.gov/mars2020-raw-images/pub/ods/surface/sol/00062/ids/edr/browse/zcam/ZL0_0062_0672439037_738ECM_N0032046ZCAM08106_110085J01_1200.jpg',
        ]


@app.route('/')
def index():
    url = choice(CHERRY_PICKS)
    name, launch, landing, status = get_rover_data(API_KEY)
    return render_template(
            'index.html', 
            url=url, 
            name=name, 
            launch=launch, 
            landing=landing,
            status=status
            )

@app.route("/sol/<int:param>/")
def go_to(param):
    url = get_mars_photo_url(param, API_KEY, CAM)
    name, launch, landing, status = get_rover_data(API_KEY)
    return render_template(
            'index.html', 
            url=url,
            name=name,
            launch=launch,
            landing=landing,
            status=status
            )

@app.route('/status')
def status():
    return '<h2>All Systems Operational</h2>'

def get_rover_data(api_key):
    params = { 'sol': 1, 'api_key': api_key}
    response = requests.get(rover_url, params).json()
    rover_data = response['photos'][0]['rover']
    rover_name = rover_data['name']
    rover_launch_date = rover_data['launch_date']
    rover_landing_date = rover_data['landing_date']
    rover_status = rover_data['status']
    return rover_name, rover_launch_date, rover_landing_date, rover_status


def get_mars_photo_url(sol, api_key, cam):
    params = { 'sol': sol, 'api_key': api_key, 'camera': cam }
    response = requests.get(rover_url, params)
    response_dictionary = response.json()
    photos = response_dictionary['photos']
    return choice(photos)['img_src']

