const { environment } = require('@rails/webpacker')
const MonacoWebpackPlugin = require('monaco-editor-webpack-plugin')

environment.plugins.append('MonacoWebpackPlugin', new MonacoWebpackPlugin())

module.exports = environment
