/* eslint-disable  func-names */
/* eslint quote-props: ["error", "consistent"]*/
/**
 * This sample demonstrates a sample skill built with Amazon Alexa Skills nodejs
 * skill development kit.
 * This sample supports multiple languages (en-US, en-GB, de-GB).
 * The Intent Schema, Custom Slot and Sample Utterances for this skill, as well
 * as testing instructions are located at https://github.com/alexa/skill-sample-nodejs-howto
 **/

'use strict';
require('dotenv').config()

const Alexa = require('alexa-sdk');
const Weather = require('./weather.js')
const Firebase = require('./firebase.js')
const Requests = require('./requests.js')

const APP_ID = process.env.ALEXA_SKILL_ID;

const handlers = {
    'LaunchRequest': function () {
       this.attributes['speechOutput'] = this.t("WELCOME_MESSAGE", this.t("SKILL_NAME"), this.t("INSTRUCTIONS"));
        // If the user either does not reply to the welcome message or says something that is not
        // understood, they will be prompted again with this text.
        this.attributes['repromptSpeech'] = this.t("WELCOME_REPROMPT");
        this.emit(':ask', this.attributes['speechOutput'], this.attributes['repromptSpeech'])
    },
    'CoffeeTypeIntent': function () {
        var util = require("util");
        console.log("CoffeeTypeIntent event ", util.inspect(this.event, {showHidden: false, depth: null}));
        const itemSlot = this.event.request.intent.slots.CoffeeType;
        let itemName;
        var coffee_type
        console.log("itemSlot: ",itemSlot)
        console.log("itemSlot.value: ",itemSlot.value)
        var that = this;
        
        if (itemSlot && itemSlot.value) {
            itemName = itemSlot.value.toLowerCase();

            if (itemName == "hot coffee") {
                coffee_type = 1
            }  else if (itemName == "iced coffee") {
                coffee_type = 0
            } else {
                console.log(itemName + " not found");

                var speechOutput = that.t("NO_COFFEE_TYPE_FOUND");
                var repromptSpeech = that.t("NOT_FOUND_REPROMPT");
            
                speechOutput += repromptSpeech;
    
                that.attributes['speechOutput'] = speechOutput;
                that.attributes['repromptSpeech'] = repromptSpeech;
    
                that.emit(':ask', speechOutput, repromptSpeech);
            }
        }
        console.log("coffee_type: " + coffee_type)
        console.log("itemName" + itemName);

        var cardTitle = that.t("REQUEST_COFFEE_CARD_TITLE", that.t("SKILL_NAME"), itemName);

        Requests.getZip(that.event)
        .then(function(json) {
            return Weather.getWeather(json.postalCode)
        }).then(function (json) {
            return Firebase.saveWeatherData(json,coffee_type)
        }).then(function (json) {
            console.log('Data saved')
            that.attributes['speechOutput'] = that.t("REQUEST_COFFEE_MESSAGE");
            that.attributes['repromptSpeech'] = that.t("REPEAT_MESSAGE");
            
            that.emit(':tellWithCard', that.t("REQUEST_COFFEE_MESSAGE"), cardTitle, that.t("REQUEST_COFFEE_MESSAGE"));
            // that.emit(':tell', "You preference of " + itemName + " was saved successfully");
       }).catch(function(err) {
           
        if (err.name == "NO_ACCESS" || err == "NO_ACCESS") {
            console.log("LOCATION_PERMISSIONS_REJECTED")
            var speechOutput = that.t("LOCATION_PERMISSIONS_REJECTED", that.t("SKILL_NAME"),that.t("SKILL_NAME"), that.t("SKILL_NAME") );                
            var permissionArray = ['read::alexa:device:all:address:country_and_postal_code'];
            that.emit(':tellWithPermissionCard', speechOutput, permissionArray);
        } else {
            console.log("CoffeeTypeIntent- err: ", err);
            var speechOutput = that.t("NOT_FOUND_MESSAGE");
            var repromptSpeech = that.t("NOT_FOUND_REPROMPT");
        
            speechOutput += repromptSpeech;

            that.attributes['speechOutput'] = speechOutput;
            that.attributes['repromptSpeech'] = repromptSpeech;

            that.emit(':ask', speechOutput, repromptSpeech);
           }
            
        });
        
       
    },
     'GetCoffeeTypeIntent': function () {
        var util = require("util");
        console.log("GetCoffeeTypeIntent event ", util.inspect(this.event, {showHidden: false, depth: null}));

        var that = this;
        Requests.getZip(that.event)
        .then(function(json) {
            return Weather.getWeather(json.postalCode)
        }).then(function(json) {
            var temp =  parseInt(json["main"]["temp"])
            var string;
            if (temp > 60) {
                string = "Iced Coffee"
            } else {
                string = "Hot Coffee"
            }
            var cardTitle = that.t("GET_COFFEE_CARD_TITLE", that.t("SKILL_NAME"), string);
            that.attributes['speechOutput'] = that.t('GET_COFFEE_OUTPUT', string);
            that.attributes['repromptSpeech'] = that.t("REPEAT_MESSAGE");
            that.emit(':tellWithCard', string, cardTitle, string);
        })
        .catch(function (err) {
            if (err.name == "NO_ACCESS" || err == "NO_ACCESS") {
                console.log("LOCATION_PERMISSIONS_REJECTED")
                var speechOutput = that.t("LOCATION_PERMISSIONS_REJECTED", that.t("SKILL_NAME"),that.t("SKILL_NAME"), that.t("SKILL_NAME") );                
                var permissionArray = ['read::alexa:device:all:address:country_and_postal_code'];
                that.emit(':tellWithPermissionCard', speechOutput, permissionArray);
            } else {
                console.log("GetCoffeeTypeIntent Error: ", err)
                var speechOutput = that.t("NOT_FOUND_MESSAGE");
                var repromptSpeech = that.t("NOT_FOUND_REPROMPT");
            
                speechOutput += repromptSpeech;

                that.attributes['speechOutput'] = speechOutput;
                that.attributes['repromptSpeech'] = repromptSpeech;

                that.emit(':ask', speechOutput, repromptSpeech);
            }
        })
       
       
    },
   'AMAZON.HelpIntent': function () {
        this.attributes['speechOutput'] = this.t("INSTRUCTIONS");
        this.attributes['repromptSpeech'] = this.t("INSTRUCTIONS");
        this.emit(':ask', this.attributes['speechOutput'], this.attributes['repromptSpeech'])
    },
    'AMAZON.RepeatIntent': function () {
        this.emit(':ask', this.attributes['speechOutput'], this.attributes['repromptSpeech'])
    },
    'AMAZON.StopIntent': function () {
        this.emit('SessionEndedRequest');
    },
    'AMAZON.CancelIntent': function () {
        this.emit('SessionEndedRequest');
    },
    'SessionEndedRequest':function () {
        this.emit(':tell', this.t("STOP_MESSAGE"));
    },
    'Unhandled': function () {
        this.attributes['speechOutput'] = this.t("INSTRUCTIONS");
        this.attributes['repromptSpeech'] = this.t("INSTRUCTIONS");
        this.emit(':ask', this.attributes['speechOutput'], this.attributes['repromptSpeech'])
    },
};

exports.handler = function (event, context) {
    const alexa = Alexa.handler(event, context);
    alexa.APP_ID = APP_ID;
    // To enable string internationalization (i18n) features, set a resources object.
    alexa.resources = languageStrings;
    alexa.registerHandlers(handlers);
    alexa.execute();
};

var languageStrings = {
    "en": {
        "translation": {
            "SKILL_NAME": "CoffeeBot",
            "INSTRUCTIONS": "You can ask what type of coffee to have, by asking me, 'What should I drink?'. Or tell me what coffee you are drinking by saying 'I'm having iced coffee', or, 'I'm having hot coffee'... Now, what can I help you with.",
            "WELCOME_MESSAGE": "Welcome to %s. %s",
            "WELCOME_REPROMPT": "For instructions on what you can say, please say help me.",
            "REQUEST_COFFEE_CARD_TITLE":"%s - Your are drinking. (%s)",
            "REQUEST_COFFEE_MESSAGE":"Thanks for your input. This will help me better predict what coffee you should have next time",


            "GET_COFFEE_CARD_TITLE":"%s - I think you should have %s",
            "GET_COFFEE_OUTPUT":"I think you should have %s",

            "STOP_MESSAGE": "Goodbye!",
            "REPEAT_MESSAGE": "Try saying repeat.",
            "NOT_FOUND_MESSAGE": "I\'m sorry, I currently do not know how to do this.",
            "NOT_FOUND_REPROMPT": "What else can I help with?",
            "NO_COFFEE_TYPE_FOUND": "I'\m sorry, I didnt hear you. Please say if you are having Hot Coffee or Iced Coffee",
            "LOCATION_PERMISSIONS_REJECTED": "You have refused to allow or have not allowed %s access to the address information in the Alexa app. %s cannot function without address information. To permit access to address information, enable %s again, and consent to provide address information in the Alexa app."
        }
    },
    "en-US": {
        "translation": {
            "SKILL_NAME" : "CoffeeBot"
        }
    }
};



