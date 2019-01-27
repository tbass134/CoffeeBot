import sys
import os
import shutil
import time
import traceback

from flask import Flask, request, jsonify
import pandas as pd
from sklearn.externals import joblib

app = Flask(__name__)

# inputs
training_data = 'data/tcoffeeBotData-Cleaned.csv'
dependent_variable = "type"

model_file_name = 'model.pkl'


# These will be populated at training time
model = joblib.load(model_file_name)

@app.route('/predict', methods=['POST'])
def predict():
    if clf:
        try:
            json_ = request.json
            query = pd.get_dummies(pd.DataFrame(json_))
            print(json_)

            # https://github.com/amirziai/sklearnflask/issues/3
            # Thanks to @lorenzori
            query = query.reindex(columns=model_columns, fill_value=0)

            prediction = list(clf.predict(query))

            return jsonify({'prediction': prediction})

        except Exception:

            return jsonify({'error': str(e), 'trace': traceback.format_exc()})
    else:
        print('train first')
        return 'no model here'

if __name__ == '__main__':
    try:
        port = int(sys.argv[1])
    except Exception:
        port = 80

    try:
        model = joblib.load(model_file_name)
        print('model loaded')

    except Exception as e:
        print(e)
        print('Train first')
        clf = None

    app.run(host='0.0.0.0', port=port, debug=True)
