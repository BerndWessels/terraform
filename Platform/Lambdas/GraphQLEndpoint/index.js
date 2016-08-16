/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

import {graphql} from 'graphql';
import Schema from './schema';

console.log('Loading function');

/**
 * Lambda entry point.
 */
exports.handler = (event, context) => {
    executeQuery(event, (error, response) => {
        return context.done(error, response);
    });
};

/**
 * Execute the GraphQL query.
 */
function executeQuery(event, callback) {
    // Get the GraphQL query from the request.
    let query = event.query;
    // Process the GraphQL query
    graphql(Schema, query).then(result => {
        //console.log('RESULT: ', result);
        return callback(null, result);
    });
}