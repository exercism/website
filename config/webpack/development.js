process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const webpackConfig = require('./base')
const { merge } = require('@rails/webpacker')
const ForkTSCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin')
const path = require('path')

module.exports = merge(webpackConfig, {
  plugins: [
    new ForkTSCheckerWebpackPlugin({
      typescript: {
        configFile: path.resolve(__dirname, '../../tsconfig.json'),
      },
      async: false,
    }),
  ],
})
