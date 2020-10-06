process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

/**
 * The default installation only transpiles your TypeScript code using Babel. If
 * you would like to enable type checking as part of the Webpack compilation
 * process (i.e. fail the build if there are TS errors), we need the following:
 */
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
