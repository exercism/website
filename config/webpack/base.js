const { webpackConfig, merge } = require('@rails/webpacker')
const customConfig = {
  resolve: {
    extensions: ['.css'],
  },
}

module.exports = merge(webpackConfig, customConfig)
