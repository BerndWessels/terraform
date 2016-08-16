/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

/**
 * Webpack config
 */
import path from 'path';
import yargs from 'yargs';
import webpack from 'webpack';
import autoprefixer from 'autoprefixer';
import HtmlWebpackPlugin from 'html-webpack-plugin';
import ExtractTextPlugin from 'extract-text-webpack-plugin';
import CleanWebpackPlugin from 'clean-webpack-plugin';
import CopyWebpackPlugin from 'copy-webpack-plugin';

/**
 * Environment type
 */
const {buildProduction, buildDevelopment} = yargs
  .alias('p', 'build-production')
  .alias('d', 'build-development')
  .argv;

let buildTest = !buildProduction && !buildDevelopment;

/**
 * Config
 * Reference: http://webpack.github.io/docs/configuration.html
 * This is the object where all configuration gets set
 */
let config = {};

/**
 * Entry
 * Reference: http://webpack.github.io/docs/configuration.html#entry
 * Should be an empty object if it's generating a test build
 * Karma will set this when it's a test build
 */
if (buildTest) {
  config.entry = {}
} else if (buildProduction) {
  config.entry = {
    app: ['babel-polyfill', './src/index.js']
  }
} else if (buildDevelopment) {
  config.entry = {
    app: ['babel-polyfill', 'webpack-dev-server/client?http://127.0.0.1:8087', './src/index.js']
  }
}

/**
 * Externals
 * Reference: http://webpack.github.io/docs/configuration.html#externals
 */
config.externals = {
};

/**
 * Output
 * Reference: http://webpack.github.io/docs/configuration.html#output
 * Should be an empty object if it's generating a test build
 * Karma will handle setting it up for you when it's a test build
 */
if (buildTest) {
  config.output = {
    path: __dirname + '/build'
  };
} else {
  config.output = {
    // Absolute output directory
    path: buildProduction ? __dirname + '/dist' : __dirname + '/public',

    // Output path from the view of the page
    // Uses webpack-dev-server in development
    // Reference: http://stackoverflow.com/questions/34133808/webpack-ots-parsing-error-loading-fonts/34133809#34133809
    publicPath: buildProduction ? '' : 'http://127.0.0.1:8087/',

    // Filename for entry points
    // Only adds hash in build mode
    filename: buildProduction ? '[name].[hash].js' : '[name].bundle.js',

    // Filename for non-entry points
    // Only adds hash in build mode
    chunkFilename: buildProduction ? '[name].[hash].js' : '[name].bundle.js'
  };
}

/**
 * Devtool
 * Reference: http://webpack.github.io/docs/configuration.html#devtool
 * Type of sourcemap to use per build type
 */
if (buildTest) {
  config.devtool = 'inline-source-map';
} else if (buildProduction) {
  config.devtool = null; // 'source-map'; use this to "debug" the production version
} else if (buildDevelopment) {
  config.devtool = 'eval';
}

config.resolve = {
  extensions: ['', '.jsx', '.scss', '.js', '.json'],
  modulesDirectories: [
    'node_modules',
    path.resolve(__dirname, './node_modules')
  ]
};

/**
 * Loaders
 * Reference: http://webpack.github.io/docs/configuration.html#module-loaders
 * List: http://webpack.github.io/docs/list-of-loaders.html
 * This handles most of the magic responsible for converting modules
 */

// Initialize module
config.module = {
  preLoaders: [],
  loaders: [{
    // JS LOADER
    // Reference: https://github.com/babel/babel-loader
    // Transpile .js files using babel-loader
    // Compiles ES6 and ES7 into ES5 code
    test: /\.js$/,
    loader: 'babel',
    exclude: /(node_modules|bower_components)/
  }, {
    // ASSET FONT LOADER
    // Reference: https://github.com/webpack/file-loader
    // Copy png, jpg, jpeg, gif, svg, woff, woff2, ttf, eot files to output
    // Rename the file using the asset hash
    // Pass along the updated reference to your code
    // You can add here any file extension you want to get copied to your output
    test: /\.(svg|woff|woff2|ttf|eot)$/,
    loader: 'file?name=assets/fonts/[name].[hash].[ext]'
  }, {
    // ASSET IMAGE LOADER
    // Reference: https://github.com/webpack/file-loader
    // Copy png, jpg, jpeg, gif, svg, woff, woff2, ttf, eot files to output
    // Rename the file using the asset hash
    // Pass along the updated reference to your code
    // You can add here any file extension you want to get copied to your output
    test: /\.(png|jpg|jpeg|gif)$/,
    loader: 'file?name=assets/images/[name].[hash].[ext]'
  }, {
    // HTML LOADER
    // Reference: https://github.com/webpack/raw-loader
    // Allow loading html through js
    test: /\.html$/,
    loader: 'html'
  }, {
    // JSON LOADER
    // Reference: https://github.com/webpack/json-loader
    // Allow loading JSNO
    test: /\.json$/,
    loader: 'json'
  }
  ]
};

// ISPARTA LOADER
// Reference: https://github.com/ColCh/isparta-instrumenter-loader
// Instrument JS files with Isparta for subsequent code coverage reporting
// Skips node_modules and files that end with .test.js
if (buildTest) {
  config.module.preLoaders.push({
    test: /\.js$/,
    exclude: [
      /(node_modules|bower_components)/,
      /\.test\.js$/
    ],
    loader: 'isparta-instrumenter'
  })
}

// BOOTSTRAP SASS LOADER
// Reference: https://github.com/jtangelder/sass-loader
// Allow loading sass/css through js
var globalSassLoader = {
  test: /(\.scss|\.css)$/,
  include: [/bootstrap/, /icomoon/],
  // Reference: https://github.com/webpack/style-loader
  // Use style-loader in development for hot-loading
  // Reference: https://github.com/webpack/css-loader
  // Reference: https://github.com/postcss/postcss-loader
  // Reference: https://github.com/jtangelder/sass-loader
  loader: (buildDevelopment || buildTest) ? 'style!css?sourceMap!postcss!resolve-url!sass?sourceMap' :
    // Reference: https://github.com/webpack/extract-text-webpack-plugin
    // Extract sass/css files in production builds
    ExtractTextPlugin.extract('css?sourceMap!postcss!resolve-url!sass?sourceMap')
};

// SASS LOADER
// Reference: https://github.com/jtangelder/sass-loader
// Allow loading sass/css through js
var sassLoader = {
  test: /(\.scss|\.css)$/,
  exclude: [/node_modules/, /bootstrap/, /icomoon/],
  // Reference: https://github.com/webpack/style-loader
  // Use style-loader in development for hot-loading
  // Reference: https://github.com/webpack/css-loader
  // Reference: https://github.com/postcss/postcss-loader
  // Reference: https://github.com/jtangelder/sass-loader
  loader: (buildDevelopment || buildTest) ? 'style!css?sourceMap&modules&importLoaders=2!postcss!resolve-url!sass?sourceMap' :
    // Reference: https://github.com/webpack/extract-text-webpack-plugin
    // Extract sass/css files in production builds
    ExtractTextPlugin.extract('css?sourceMap&modules&importLoaders=2!postcss!resolve-url!sass?sourceMap')
};

// Skip loading css in test mode
if (buildTest) {
  // Reference: https://github.com/webpack/null-loader
  // Return an empty module
  globalSassLoader.loader = 'null';
  sassLoader.loader = 'null';
}

// Add cssLoader to the loader list
config.module.loaders.push(globalSassLoader);
config.module.loaders.push(sassLoader);

/**
 * PostCSS
 * Reference: https://github.com/postcss/autoprefixer-core
 * Add vendor prefixes to your css
 */
config.postcss = [
  autoprefixer({
    browsers: ['last 2 version']
  })
];

/**
 * Plugins
 * Reference: http://webpack.github.io/docs/configuration.html#plugins
 * List: http://webpack.github.io/docs/list-of-plugins.html
 */
config.plugins = [
  // Reference: https://github.com/webpack/extract-text-webpack-plugin
  // Extract css files
  // Disabled when in test mode or not in build mode
  new ExtractTextPlugin('[name].[hash].css', {
    disable: buildDevelopment || buildTest
  }),
  // Reference: http://mts.io/2015/04/08/webpack-shims-polyfills
  // Inject a polyfill for the given key words
  new webpack.ProvidePlugin({
    'fetch': 'imports?this=>global!exports?global.fetch!whatwg-fetch'
  })
];
// Skip rendering index.html in test mode
if (!buildTest) {
  // Reference: https://github.com/ampedandwired/html-webpack-plugin
  // Render index.html
  config.plugins.push(
    new HtmlWebpackPlugin({
      template: './src/index.ejs',
      inject: false,
      baseurl: process.env.BASEURL || '/',
      favicon: './public/favicon.ico'
    })
  );
}

// Add build specific plugins
if (buildProduction) {
  // Reference: https://github.com/jeffling/ng-annotate-webpack-plugin
  // Make Angular Injections minification safe
  config.plugins.push(
    // Reference: https://github.com/johnagan/clean-webpack-plugin
    // Clean the output folders before building
    new CleanWebpackPlugin(['dist', 'build'], __dirname),
    // Reference: https://github.com/kevlened/copy-webpack-plugin
    // Copy the public folder to the dist folder
    new CopyWebpackPlugin([
      {from: 'public'}
    ]),
    // Reference: http://webpack.github.io/docs/list-of-plugins.html#dedupeplugin
    // Dedupe modules in the output
    new webpack.optimize.DedupePlugin(),
    // Reference: http://webpack.github.io/docs/list-of-plugins.html#uglifyjsplugin
    // Minify all javascript, switch loaders to minimizing mode
    new webpack.optimize.UglifyJsPlugin(),
    // Reference: http://webpack.github.io/docs/list-of-plugins.html#noerrorsplugin
    // Only emit files when there are no errors
    new webpack.NoErrorsPlugin()
  )
}

// Add dev specific plugins
if (buildDevelopment) {
  config.plugins.push(
    // https://webpack.github.io/docs/list-of-plugins.html#occurenceorderplugin
    new webpack.optimize.OccurenceOrderPlugin(),
    // Reference: https://github.com/gaearon/react-hot-loader/issues/127
    // https://webpack.github.io/docs/list-of-plugins.html#hotmodulereplacementplugin
    // new webpack.HotModuleReplacementPlugin(),
    // https://github.com/webpack/webpack/issues/701
    new webpack.OldWatchingPlugin(),
    // https://webpack.github.io/docs/list-of-plugins.html#dedupeplugin
    new webpack.optimize.DedupePlugin(),
    // Only emit files when there are no errors
    // Reference: http://webpack.github.io/docs/list-of-plugins.html#noerrorsplugin
    new webpack.NoErrorsPlugin()
  )
}

/**
 * Dev server configuration
 * Reference: http://webpack.github.io/docs/configuration.html#devserver
 * Reference: http://webpack.github.io/docs/webpack-dev-server.html
 */
config.devServer = {
  contentBase: './public',
  port: 8087,
  stats: {
    modules: false,
    cached: false,
    colors: true,
    chunk: false
  },
  /**
   * If you run `webpack ... --https` you have to provide you domain certificates.
  cert: fs.readFileSync('../certificates/dev.com.crt'),
  key: fs.readFileSync('../certificates/dev.com.key')
   */
};

export default config;
