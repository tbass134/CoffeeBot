import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import pandas as pd
from pygeocoder import Geocoder, GeocoderError
import time

GOOGLE_APPLICATION_CREDENTIALS = "coffeechooser-firebase-adminsdk-6gocx-9116ac6209.json"
cred = credentials.Certificate("coffeechooser-firebase-adminsdk-6gocx-9116ac6209.json")

firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://coffeechooser.firebaseio.com'
})

def getData():
	df = saveFile()
	for index,rows in df.iterrows():
		lat = df.loc[index, 'lat']
		lon = df.loc[index, 'lon']
		zipcode = df.loc[index, 'zipcode']
		if zipcode.isnull():
			try:
				zipcode = geocode(lat, lon)
				df.loc[index, 'zipcode'] = zipcode
				print("geocoding {} {}".format(index, zipcode))
				time.sleep(1)
			except Exception as e:
				df.to_csv('data_new.csv')

	return df

def saveFile():
	try:
		df =  pd.read_csv('data_new.csv')
		df = df.where((pd.notnull(df)), None)
		return df
	except Exception as e:
		ref = db.reference('')
		data = ref.get()
		return pd.DataFrame.from_dict(data, orient='index')
		

def geocode(lat, lon):
	try:
		results = Geocoder.reverse_geocode(lat, lon)
		return results[0].postal_code
	except Exception as e:
		print (e.status)
		if e.status != GeocoderError.G_GEO_ZERO_RESULTS:
		# Raise except if OVER_USAGE_LIMIT
			raise
		return None

data = getData()
data.to_csv('data_new.csv')
