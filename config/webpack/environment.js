const { environment } = require('@rails/webpacker')
const MonacoWebpackPlugin = require('monaco-editor-webpack-plugin')
const aliases = {
  vscode: require.resolve('monaco-languageclient/lib/vscode-compatibility'),
}

environment.config.merge({ resolve: { alias: aliases } })
environment.plugins.append('MonacoWebpackPlugin', new MonacoWebpackPlugin())

module.exports = environment
