var request = require("request");

exports.getZip = function(data) {
    return new Promise(function (resolve, reject) {
        var event = data.event
        try {
            var deviceId = event.context.System.device.deviceId
            consentToken = event.context.System.user.permissions.consentToken
            apiEndpoint = event.context.System.apiEndpoint 

             if(!consentToken || !deviceId || !apiEndpoint) {
                throw {name:"NO_ACCESS", message:"LOCATION_ACCESS_FAILED"}
            }
            console.log('get user zip code deviceId: ' + deviceId + " consentToken: " + consentToken + " apiEndpoint: " + apiEndpoint)
            
            var options = {
                method: 'GET',
                url: apiEndpoint + '/v1/devices/' + deviceId + '/settings/address/countryAndPostalCode',
                headers:
                { authorization: 'Bearer ' + consentToken }
            };

            console.log('making request with options', options);

            request(options, function (error, response, body) {
                if (error) {reject(error); console.log('getZipError: ', error); return;}

                var json = JSON.parse(body)
                if (response.statusCode > 300) {
                    console.log('getZipError: ', json);
                    reject("NO_ACCESS")
                    return
                }
                console.log('getZipSUccess: ', json);
                data.location = json
                resolve(data)

            });
        } catch(e) {
            reject("NO_ACCESS")
        }
    });

}
