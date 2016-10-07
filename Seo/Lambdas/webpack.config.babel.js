/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

'use strict';

/**
 * Import dependencies.
 */
var fs = require('fs');
var path = require('path');
var webpack = require('webpack');
var CleanWebpackPlugin = require('clean-webpack-plugin');
var ZipWebpackPlugin = require('./zip-webpack-plugin');

/**
 * Export the lambda build configuration.
 */
module.exports = {
    // Create an entry for each lambda function.
    entry: fs.readdirSync(__dirname)
        .filter(item => fs.statSync(path.join(__dirname, item)).isDirectory())
        .map(lambdaFolder => {
            var entry = {};
            entry[lambdaFolder] = path.join(__dirname, lambdaFolder, 'index.js');
            return entry;
        })
        .reduce((finalObject, entry) => Object.assign(finalObject, entry), {}),
    // The aws-sdk dependency is already provided by AWS.
    externals: {
        "aws-sdk": true
    },
    // Set the build target folder.
    output: {
        path: path.join(__dirname, '../Lambdas'),
        library: '[name]',
        libraryTarget: 'commonjs2',
        filename: '[name]/.[name].compiled.js'
    },
    // Build for node js.
    target: 'node',
    // Configure the module.
    module: {
        // Setup the loaders.
        loaders: [{
            // ES6 loader.
            test: /\.js$/,
            exclude: /node_modules/,
            loader: 'babel'
        }, {
            // JSON loader.
            test: /\.json$/,
            loader: 'json'
        }]
    },
    // Add the plugins.
    plugins: [
        // Clean the output folders.
        new CleanWebpackPlugin(['lambdas'], {root: path.join(__dirname, '../dist')}),
        // Uglify the output files.
        new webpack.optimize.UglifyJsPlugin({/*mangle: { except: ['exports', 'require']}}*/}),
        //
        new ZipWebpackPlugin({})
    ]
};
