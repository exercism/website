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
