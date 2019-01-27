import requests
import dateutil.parser
import os
from os.path import join, dirname
from dotenv import load_dotenv

dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)


BASE_URL = 'http://api.wunderground.com/api'
API_KEY = 'a92ac80f0015d69b' #os.environ.get('WEATHER_UNDERGROUND_API_KEY')

def getWeatherConditions(city, state, date):

	day = date.strftime("%Y%m%d")
	print(day)
	hour = date.strftime("%H")
	print(hour)

	url = BASE_URL+"/"+API_KEY+"/history_"+day+"/q/"+state+"/"+city+".json"
	print(url)
	response = requests.request("GET", url)
	json = response.json()

	observations = json['history']['observations']
	for date in observations:
		if date['date']['hour'] == hour:
			return date['conds']
	return None

def getLocationFromZip(zip):
	url = BASE_URL+"/"+API_KEY+"/geolookup/q/"+zip+".json"
	response = requests.request("GET", url)
	json = response.json()
	print(json['location']['city'])
	print(json['location']['state'])
	return (json['location']['city'], json['location']['state'])





d = dateutil.parser.parse('2018-01-09T17:45:30.285Z')
zip = '10923'
city, state = getLocationFromZip(zip)
condition = getWeatherConditions(city, state, d)
print(condition)

# import json
# from pprint import pprint

# data = json.load(open('response.json'))

# observations = data['history']['observations']
# for date in observations:
# 	hour = date['date']['hour']
# 	if hour == '14':
# 		print(date['conds'])

# pprint(data['history'])
