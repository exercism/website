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

const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin')
const isWebpackDevServer = process.env.WEBPACK_DEV_SERVER
if (isWebpackDevServer) {
  environment.plugins.append(
    'ReactRefreshWebpackPlugin',
    new ReactRefreshWebpackPlugin({
      overlay: {
        sockPort: 3035,
      },
    })
  )
}

module.exports = environment.toWebpackConfig()
