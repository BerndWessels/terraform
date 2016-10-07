/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

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
    console.log('Received event:', JSON.stringify(event, null, 2));
    return callback(null, {statusCode: 200, headers:{"Content-Type": "text/html"}, body: "<html><head><title>SEO Website</title></head><body><h1>SEO Website</h1></body></html>"});
}
