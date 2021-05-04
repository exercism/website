const { environment } = require('@rails/webpacker')

let ASSET_HOST

if (process.env.NODE_ENV === 'production') {
  ASSET_HOST =
    'https://exercism-assets-staging.s3.eu-west-2.amazonaws.com/packs/'
} else {
  ASSET_HOST = ''
}

module.exports = environment
