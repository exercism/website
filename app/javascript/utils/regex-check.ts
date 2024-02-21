declare global {
  interface RegExpMatchArray {
    indices?: number[][]
  }
}

export function areAllRegExpFeaturesSupported(): boolean {
  try {
    const namedCaptureGroupsTest = new RegExp('(?<name>.*)')
    if (!namedCaptureGroupsTest.exec('test')?.groups?.name) return false
  } catch (e) {
    return false
  }

  try {
    const lookbehindAssertionsTest = new RegExp('(?<=a)b')
    if ('ab'.search(lookbehindAssertionsTest) === -1) return false
  } catch (e) {
    return false
  }

  try {
    const unicodePropertyEscapesTest = new RegExp('\\p{Script=Latin}', 'u')
    if (!'a'.match(unicodePropertyEscapesTest)) return false
  } catch (e) {
    return false
  }

  try {
    const dotAllFlagTest = new RegExp('.', 's')
    if (!dotAllFlagTest.test('\n')) return false
  } catch (e) {
    return false
  }

  try {
    const hasIndicesFlagTest = new RegExp('.', 'd')
    if ('a'.match(hasIndicesFlagTest)?.indices === undefined) return false
  } catch (e) {
    return false
  }

  return true
}
