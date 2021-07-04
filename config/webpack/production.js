process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const webpackConfig = require('./base')

webpackConfig.merge({
  output: {
    publicPath:
      'https://exercism-assets-staging.s3.eu-west-2.amazonaws.com/packs/',
  },
})

module.exports = webpackConfig
