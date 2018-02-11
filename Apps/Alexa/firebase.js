var firebaseAdmin = require("firebase-admin")
var privateKey = null
try {
    privateKey = JSON.parse(process.env.FIREBASE_ADMIN_PRIVATE_KEY)
} catch (e) {
    privateKey = process.env.FIREBASE_ADMIN_PRIVATE_KEY
}

firebaseAdmin.initializeApp({
    credential: firebaseAdmin.credential.cert({
        "private_key": privateKey,
        "client_email": process.env.FIREBASE_ADMIN_CLIENT_EMAIL,

    }),
    databaseURL: process.env.FIREBASE_DB
}
)
firebaseDatabase = firebaseAdmin.database()


exports.saveWeatherData = function (json, coffee_type) {
    return new Promise(function (resolve, reject) {
        var database = firebaseAdmin.database();
        const uuidV1 = require('uuid/v1');
        var ref = database.ref(uuidV1());
        var item = {
            device: "Alexa",
            type: coffee_type,
            date: new Date().toISOString(),
            temp: json["main"]["temp"],
            humidity: json["main"]["humidity"],
            location: json["name"],
            lat: json["coord"]["lat"],
            lon: json["coord"]["lon"],
            weatherCond: json["weather"][0]["main"],
            clouds: json["clouds"]["all"],
            visibility: json["visibility"],
            windSpeed: json["wind"]["speed"],
            windDeg: json["wind"]["deg"],
            pressure: json["main"]["pressure"]
        }
        ref.set(item, function (error) {
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