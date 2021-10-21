const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend(
  'Environment',
  new webpack.EnvironmentPlugin(
    JSON.parse(
      JSON.stringify({
        // TODO: @iHiD Should we get this from Exercism::Config?
        BUGSNAG_API_KEY: '938ae3d231c5455e5c6597de1b1467af',
      })
    )
  )
)

environment.loaders.get('babel').use = [
  { loader: 'esbuild-loader', options: { loader: 'tsx', target: 'es2015' } },
]
environment.loaders.get('nodeModules').use = [
  { loader: 'esbuild-loader', options: { loader: 'jsx', target: 'es2015' } },
]

environment.splitChunks()
module.exports = environment
