tw = require('./tailwind.config.js')
tw.content = []
tw.corePlugins = {
  container: false,
  preflight: false,
}
module.exports = tw
