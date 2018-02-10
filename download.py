import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import pandas as pd
import numpy as np
from pygeocoder import Geocoder, GeocoderError
import time
import os

from os.path import join, dirname
from dotenv import load_dotenv

dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)

GOOGLE_APPLICATION_CREDENTIALS = os.environ.get("PATH_TO_GOOGLE_APPLICATION_CREDENTIALS")
cred = credentials.Certificate(GOOGLE_APPLICATION_CREDENTIALS)
csv_file = os.environ.get('csv_file')

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
		# if np.isnan(df.loc[index, 'zipcode']):
		if pd.isnull(df.loc[index, 'zipcode']):
			try:
				zipcode = geocode(lat, lon)
				df.loc[index, 'zipcode'] = str(zipcode)
				print("geocoding {} {}".format(index, zipcode))
				time.sleep(20)
			except Exception as e:
				print(e)

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
		return results[0].postal_code
	except Exception as e:
		print (e.status)
		if e.status != GeocoderError.G_GEO_ZERO_RESULTS:
		# Raise except if OVER_USAGE_LIMIT
			raise
		return None


data = loadData()
data = updateZipCodes(data)
data.to_csv(csv_file)
