process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

environment.config.merge({
  output: {
    publicPath: 'https://exercism-v3-assets.s3.eu-west-2.amazonaws.com/packs/',
  },
})

module.exports = environment.toWebpackConfig()
