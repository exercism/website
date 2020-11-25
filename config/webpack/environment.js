const { environment } = require('@rails/webpacker')
const MonacoWebpackPlugin = require('monaco-editor-webpack-plugin')
const aliases = {
  vscode: require.resolve('monaco-languageclient/lib/vscode-compatibility'),
}

environment.config.merge({ resolve: { alias: aliases } })

let ASSET_HOST

if (process.env.NODE_ENV === 'production') {
  ASSET_HOST =
    'https://exercism-assets-staging.s3.eu-west-2.amazonaws.com/packs/'
} else {
  ASSET_HOST = ''
}

environment.plugins.append(
  'MonacoWebpackPlugin',
  new MonacoWebpackPlugin({
    publicPath: ASSET_HOST,
  })
)

module.exports = environment
