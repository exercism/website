const path = {
  sep: '/',
  delimiter: ':',

  resolve: (...args) => {
    let resolvedPath = ''
    for (const segment of args) {
      if (segment.startsWith('/')) {
        resolvedPath = segment
      } else {
        resolvedPath += '/' + segment
      }
    }
    return resolvedPath.replace(/\/+/g, '/')
  },

  join: (...args) => {
    return args.join('/').replace(/\/+/g, '/')
  },

  basename: (p) => {
    return p.split('/').pop()
  },

  dirname: (p) => {
    const parts = p.split('/')
    parts.pop()
    return parts.length === 0 ? '.' : parts.join('/')
  },

  extname: (p) => {
    const base = p.split('/').pop() || ''
    const dot = base.lastIndexOf('.')
    return dot !== -1 ? base.slice(dot) : ''
  },

  relative: (from, to) => {
    if (from === to) return ''
    const fromParts = from.split('/')
    const toParts = to.split('/')
    while (fromParts.length && toParts.length && fromParts[0] === toParts[0]) {
      fromParts.shift()
      toParts.shift()
    }
    return '../'.repeat(fromParts.length) + toParts.join('/')
  },
}

module.exports = path
