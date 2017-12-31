from firebase import firebase
firebase = firebase.FirebaseApplication('https://coffeechooser.firebaseio.com', None)
result = firebase.get('/', None, {'print': 'pretty'})
print (result)