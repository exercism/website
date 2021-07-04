process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const webpackConfig = require('./base')

// Enable type checking as part of the Webpack compilation process
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin')
const path = require('path')

webpackConfig.plugins.append(
  'ForkTsCheckerWebpackPlugin',
  new ForkTsCheckerWebpackPlugin({
    typescript: {
      configFile: path.resolve(__dirname, '../../tsconfig.json'),
    },
    async: false,
  })
)

module.exports = webpackConfig
