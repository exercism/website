process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

// Enable type checking as part of the Webpack compilation process
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin')
const path = require('path')

environment.plugins.append(
  'ForkTsCheckerWebpackPlugin',
  new ForkTsCheckerWebpackPlugin({
    typescript: {
      configFile: path.resolve(__dirname, '../../tsconfig.json'),
    },
    async: false,
  })
)

module.exports = environment.toWebpackConfig()
