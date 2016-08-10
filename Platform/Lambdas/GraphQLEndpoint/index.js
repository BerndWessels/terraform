'use strict';
console.log('Loading function');

exports.handler = (event, context, callback) => {
    //console.log('Received event:', JSON.stringify(event, null, 2));
    console.log('value1 =', event.key1);
    console.log('value2 =', event.key2);
    console.log('value3 =', event.key3);
    var result = {something: event.key1};
    console.log(JSON.stringify(result, null, 2));
    callback(null, result);  // Echo back the first key value
    // callback('Something went wrong');
};