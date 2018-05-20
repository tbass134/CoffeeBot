var request = require("request");

exports.getWeather = function (data) {
    var postalCode = data.location.postalCode
    return new Promise(function (resolve, reject) {
        var options = {
            method: 'GET',
            url: 'http://api.openweathermap.org/data/2.5/weather',
            qs: { zip: postalCode+',us', appid: process.env.OPEN_WEATHER_API_KEY, units:'imperial' }
        };

        request(options, function (error, response, body) {
            if (error) { reject(error); return; }

            var weather = JSON.parse(body)
            weather.zipcode = postalCode
            data.weather = weather
            resolve(data)
        });
    });
}