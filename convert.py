import pickle
#load model
file = open('svc.sav', 'rb')
svc = pickle.load(file)
print svc
# #covert to coreml
from coremltools.converters import sklearn
coreml_model = sklearn.convert(svc) 
print(type(coreml_model))

coreml_model.short_description = "Predict coffee type"
coreml_model.input_description["input"] = "weather data"
# coreml_model.output_description["prediction"] = "hot or iced coffee"
print(coreml_model.short_description)

coreml_model.save('coffee_prediction.mlmodel')