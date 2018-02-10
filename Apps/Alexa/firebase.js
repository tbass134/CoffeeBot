const firebase = require('firebase')

firebase.initializeApp({
  apiKey: " AIzaSyBkHrCaOmDeYLax6GLDNDzsz03V0QpLxQQ",                        
  authDomain: "CoffeeChooser.firebaseapp.com",        
  databaseURL: "https://CoffeeChooser.firebaseio.com"
});


exports.saveWeatherData = function(json, coffee_type) {
    return new Promise(function (resolve, reject) {
        var database = firebase.database();
        const uuidV1 = require('uuid/v1');
        var ref = database.ref(uuidV1());
        var item = {
            device:"Alexa",
            type: coffee_type,
            date:new Date().toISOString(),
            temp: json["main"]["temp"],
            humidity: json["main"]["humidity"],
            location: json["name"],
            lat: json["coord"]["lat"],
            lon: json["coord"]["lon"],
            weatherCond:  (typeof json["weather"]["main"] == "undefined") ? "" : json["weather"]["main"],
            clouds: json["clouds"]["all"],
            visibility: json["visibility"],
            windSpeed: json["wind"]["speed"],
            windDeg: json["wind"]["deg"],
            pressure: json["main"]["pressure"]
        }
        ref.set(item, function(error) {
            if (error) {
                console.log("Data could not be saved." + error);
                reject(error)
            } else {
                console.log("Data saved successfully.");
                resolve()
            }
        });
      
    });
}