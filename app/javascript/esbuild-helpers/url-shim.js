function pathToFileURL(filepath) {
  const url = new URL('file://' + filepath.replace(/\\/g, '/'))
  return url
}

class URL {
  constructor(input) {
    this.href = input
    this.toString = () => input
  }
}

module.exports = {
  URL,
  pathToFileURL,
}
