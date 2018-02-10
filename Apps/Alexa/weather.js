var request = require("request");

exports.getWeather = function (zip_code) {

    return new Promise(function (resolve, reject) {
        var options = {
            method: 'GET',
            url: 'http://api.openweathermap.org/data/2.5/weather',
            qs: { zip: zip_code+',us', appid: 'c19b462dd451aca86e5eab051726907d', units:'imperial' }
        };

        request(options, function (error, response, body) {
            if (error) { reject(error); return; }

            var json = JSON.parse(body)
            resolve(json)
        });
    });
}