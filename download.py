import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import pandas as pd
import numpy as np
from pygeocoder import Geocoder, GeocoderError
import time
import os
import requests
import dateutil.parser

from os.path import join, dirname
from dotenv import load_dotenv

dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)

GOOGLE_APPLICATION_CREDENTIALS = os.environ.get("PATH_TO_GOOGLE_APPLICATION_CREDENTIALS")
cred = credentials.Certificate(GOOGLE_APPLICATION_CREDENTIALS)
csv_file = os.environ.get('csv_file')

W_UNDERGROUND_BASE_URL = 'http://api.wunderground.com/api'
W_UNDERGROUND_API_KEY = os.environ.get('WEATHER_UNDERGROUND_API_KEY')


firebase_admin.initialize_app(cred, {
    'databaseURL': os.environ.get('databaseURL')
})

def loadFirebaseDB():
	ref = db.reference('')
	data = ref.get()
	df = pd.DataFrame.from_dict(data, orient='index')
	df.fillna(np.nan, inplace=True)
	return df

def updateZipCodes(df):
	for index,rows in df.iterrows():
		lat = df.loc[index, 'lat']
		lon = df.loc[index, 'lon']
		print(df.loc[index, 'zipcode'])
		if pd.isnull(df.loc[index, 'zipcode']):
			try:
				zipcode = geocode(lat, lon)
				df.loc[index, 'zipcode'] = str(zipcode)
				print("geocoding {} {}".format(index, zipcode))
				time.sleep(5)
			except Exception as e:
				print(e)
				time.sleep(5)
		if pd.isnull(df.loc[index, 'weatherCond']):
			try:
				zipcode = str(df.loc[index, 'zipcode'])
				date = str(df.loc[index, 'date'])
				# print("get weather condition zip:{} date:{}".format(zipcode, date))
				d = dateutil.parser.parse(date)
				print(d)
				city, state = getLocationFromZip(zipcode)
				time.sleep(5)
				condition = getWeatherConditions(city, state, d)
				df.loc[index, 'weatherCond'] = str(condition)
				print("condition {} {}".format(index, condition))
			except Exception as e:
				print("error {}".format(e))
				time.sleep(5)


	return df

def loadData():
	"""load data from firebase
		append saved data
		remove dups """
	firebase_df = loadFirebaseDB()
	if os.path.exists(csv_file):
		saved_df = pd.read_csv(csv_file, index_col=0)
		combined_df  = pd.concat([saved_df,firebase_df]).drop_duplicates(subset=['date'])
		return combined_df
	else:
		return firebase_df

def geocode(lat, lon):
	try:
		results = Geocoder.reverse_geocode(lat, lon)
		time.sleep(5)
		return results[0].postal_code
	except Exception as e:
		print (e.status)
		if e.status != GeocoderError.G_GEO_ZERO_RESULTS:
			raise
		time.sleep(5)
		return None

def getWeatherConditions(city, state, date):

	day = date.strftime("%Y%m%d")
	print(day)
	hour = date.strftime("%H")
	print(hour)

	url = W_UNDERGROUND_BASE_URL+"/"+W_UNDERGROUND_API_KEY+"/history_"+day+"/q/"+state+"/"+city.replace(" ","_")+".json"
	print(url)
	response = requests.request("GET", url)
	json = response.json()

	observations = json['history']['observations']
	for date in observations:
		if date['date']['hour'] == hour:
			return date['conds']
	return None

def getLocationFromZip(zip):
	url = W_UNDERGROUND_BASE_URL+"/"+W_UNDERGROUND_API_KEY+"/geolookup/q/"+zip+".json"
	response = requests.request("GET", url)
	json = response.json()
	print(json['location']['city'])
	print(json['location']['state'])
	return (json['location']['city'], json['location']['state'])


#in the IOS app, the coffee type(hot or iced) was stored as '2'
#however in the Alexa skill, it was stored as '1'
#this function just converts any '2' to '1'
def convertCoffeeType(x):
    if x == 2:
        return 1
    else:
        return x

data = loadData()
data = updateZipCodes(data)

#Perform some minor cleanup
data['type'] = data['type'].apply(convertCoffeeType)

#replace nan values in `device` with `ios` since these values came from the ios app, which did not set `device`
data['device'].fillna('IOS', inplace=True)



data.to_csv(csv_file)
