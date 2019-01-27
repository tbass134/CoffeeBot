import pickle
import argparse, sys

parser=argparse.ArgumentParser()

parser.add_argument('--model', help='path to model')
parser.add_argument('--output', help='path to output for model')

args=parser.parse_args()

model_path = args.model
output_path = args.output

print(model_path)
if model_path is None or output_path is None: 
	print("need both model and output path")

#load model
file = open(model_path, 'rb')
svc = pickle.load(file)
print (svc)

# #covert to coreml
from coremltools.converters import sklearn
coreml_model = sklearn.convert(svc) 
print(type(coreml_model))

coreml_model.short_description = "Predict coffee type"
coreml_model.input_description["input"] = "weather data"
# coreml_model.output_description["prediction"] = "hot or iced coffee"
print(coreml_model.short_description)

coreml_model.save('models/coffee_prediction.mlmodel')