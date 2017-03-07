/*
 * -------------------------------------------------------------------------------
 * webpack.config-elm.js
 * Build for the Elm client.
 * -------------------------------------------------------------------------------
 */
var webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin')
var path = require('path');

const CommonsChunkPlugin = webpack.optimize.CommonsChunkPlugin
const OccurenceOrderPlugin = webpack.optimize.OccurenceOrderPlugin

const ELM_START = path.resolve(__dirname, 'client', 'elm', 'src', 'index.js')
const BUILD_PATH = path.resolve(__dirname, 'static', 'js')
const MODULE_DIRS = ['node_modules']
const ELM_SOURCE = path.resolve(__dirname, 'client', 'elm')

module.exports = {
  entry: {
    'elm-vendor': [
      'socket.io-client/lib/index.js'
    ],
    'elm': ELM_START
  },
  resolve: {
    root: __dirname,
    extensions: ['', '.js', '.css', '.elm'],
    modulesDirectories: MODULE_DIRS
  },
  output: {
    path: BUILD_PATH,
    filename: '[name].mwemr-bundle.js',
    chunkFilename: '[id].mwemr-bundle.js'
  },
  plugins: [
    new OccurenceOrderPlugin(),
    new ExtractTextPlugin('elm.styles.css')
  ],
  module: {
    loaders: [
      {
        // Extract the CSS during the build.
        test: /\.css$/,
        loader: ExtractTextPlugin.extract('style', 'css')
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack?cwd=' + ELM_SOURCE
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&minetype=application/font-woff"
      },
      {
        test: /\.(ttf)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=application/octet-stream"
      },
      {
        test: /\.(eot)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "file"
      },
      {
        test: /\.(svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=image/svg+xml"
      }
    ],
    noParse: [/.elm$/]
  }
};
