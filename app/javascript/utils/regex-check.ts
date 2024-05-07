import UAParser from 'ua-parser-js'

declare global {
  interface RegExpMatchArray {
    indices?: number[][]
  }
}

export function areAllRegExpFeaturesSupported(): boolean {
  try {
    const lookbehindAssertionsTest = new RegExp('(?<=a)b')
    if ('ab'.search(lookbehindAssertionsTest) === -1) return false
  } catch (e) {
    console.log('Lookbehind is not supported:', e)
    return false
  }

  return true
}

function compareVersions(versionA: string, versionB: string): number {
  const partsA = versionA.split('.').map(Number)
  const partsB = versionB.split('.').map(Number)

  for (let i = 0; i < Math.max(partsA.length, partsB.length); i++) {
    const partA = partsA[i] || 0
    const partB = partsB[i] || 0

    if (partA > partB) {
      return 1
    } else if (partA < partB) {
      return -1
    }
  }

  return 0
}

export function isLookbehindSupported(): boolean {
  const parser = new UAParser().getBrowser()

  switch (parser.name) {
    case 'IE':
    case 'Opera mini':
      return false
    case 'Chrome': {
      if (parser.version) return compareVersions(parser.version, '62') >= 0
    }
    case 'Edge': {
      if (parser.version) return compareVersions(parser.version, '79') >= 0
    }
    case 'Firefox': {
      if (parser.version) return compareVersions(parser.version, '78') >= 0
    }
    case 'Safari': {
      if (parser.version) return compareVersions(parser.version, '16.4') >= 0
    }
    case 'Mobile Safari': {
      if (parser.version) return compareVersions(parser.version, '16.4') >= 0
    }
    case 'Opera': {
      if (parser.version) return compareVersions(parser.version, '49') >= 0
    }
    case 'Opera Mobile': {
      if (parser.version) return compareVersions(parser.version, '80') >= 0
    }
    case 'Samsung Internet': {
      if (parser.version) return compareVersions(parser.version, '8.2') >= 0
    }
    case 'UCBrowser': {
      if (parser.version) return compareVersions(parser.version, '15.5') >= 0
    }
    case 'Android Browser': {
      if (parser.version) return compareVersions(parser.version, '124') >= 0
    }
    case 'QQ Browser': {
      if (parser.version) return compareVersions(parser.version, '14.9') >= 0
    }
    case 'Baidu Browser': {
      if (parser.version) return compareVersions(parser.version, '13.52') >= 0
    }
    case 'KaiOS Browser': {
      if (parser.version) return compareVersions(parser.version, '3.1') >= 0
    }
    default:
      return true
  }
}
