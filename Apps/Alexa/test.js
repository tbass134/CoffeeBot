var event = { version: '1.0',
session: 
{ new: false,
sessionId: 'amzn1.echo-api.session.482f02ac-8c2c-48d6-9444-8aac327972ef',
application: { applicationId: 'amzn1.ask.skill.bc15fa0f-c1d5-4c4e-963c-26eb1729a5ca' },
attributes: 
{ speechOutput: 'Welcome to CoffeeBot. You can ask a question like, what\'s the recipe for a chest? ... Now, what can I help you with.',
repromptSpeech: 'For instructions on what you can say, please say help me.' },
user: 
{ userId: 'amzn1.ask.account.AHN2FWDYP47EFAZZRG4ISHKJ65I2N2HJU6TH2AHAYHXADRP4YDPA5HEDDXVLG7OKPV5UXLJGVDMIBQPOCXSOMBGAXKSBVL64QFP44K6YUK4G3BG5OP3RILH2BLFWXMR6SPQW7SH2SKLPRTKR52ZUCWXOMOR2PK4P6BH752O4NTBQYVV45DXWI44S6Y5TU7CDNOCW5BKQUHDCIAA',
permissions: { consentToken: 'Atza|IwEBIHoIaYxsQRBmqc7WRnKUzEyTnMXCw1Bu4cPlXTJfpe3x3bDGdTAJ38el0rjr4LgqeED7A5ko7rcgm_WEAJ6Bx0eTigfx5n-PiZ5e6icNq_n6KjAgtMOzUthF9yQuQhKTuur800QKrf2QZR5laAHs-ZmCz5Idg2slc4Z0uf91u-0Vw-u8_E6hdEKg5w4JhAfxYGnQ6cIVhAqijm_4po8OcqHZUm2LcjjUJXcylyD8D8QiM9Eq2ncOTsrC8MqOsmz0CPCMhNC2TGhAU3MTzp7lipqzES-krPkPdTMmhfP0IhySFEJpPPIrIxfBZHIqHC3xOQ88eK9KToahEoKXoH58e2SP5YIR2H6zUZCvkcbGlE0WdJh0h5oGf7048UFA7Ryl--ZRP6h3chPbkWpJeH_rOGhTj5vtjRXUM9zI9aNywYIvi4QdX92wbuvvTZxbWAS56JIhZXHNlRu9CzjJGCFHeJos0lZnG_lT800jlg-znjGAaw' } } },
context: 
{ AudioPlayer: { playerActivity: 'STOPPED' },
 },
request: 
{ type: 'IntentRequest',
requestId: 'amzn1.echo-api.request.f08ab2d9-2c06-4ab9-a73a-724487926472',
timestamp: '2017-06-30T20:01:31Z',
locale: 'en-US',
intent: { name: 'GetCoffeeTypeIntent', confirmationStatus: 'NONE' },
dialogState: 'STARTED' } }





const Requests = require('./requests.js')
Requests.getZip(event)
.then(function (res) {
    console.log(res)
}).catch(function (err) {
    if (err.name == "NO_ACCESS" || err == "NO_ACCESS") {
        console.log('here');
    } else {
        console.log('final ', err)
    }
})