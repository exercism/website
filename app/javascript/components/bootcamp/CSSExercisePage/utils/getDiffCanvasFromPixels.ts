export function getDiffCanvasFromPixels(
  actualPixels: Uint8ClampedArray | null,
  expectedPixels: Uint8ClampedArray | null,
  width: number,
  height: number
): { canvas: HTMLCanvasElement; differentPixels: number } | null {
  if (!actualPixels || !expectedPixels) return null
  if (actualPixels.length !== expectedPixels.length) return null

  const expectedLength = width * height * 4
  if (actualPixels.length !== expectedLength) {
    console.error('Pixel data does not match width/height dimensions.')
    return null
  }

  const diffPixels = new Uint8ClampedArray(expectedLength)

  const threshold = 0
  let differentPixels = 0

  for (let i = 0; i < actualPixels.length; i += 4) {
    const rDiff = Math.abs(actualPixels[i] - expectedPixels[i])
    const gDiff = Math.abs(actualPixels[i + 1] - expectedPixels[i + 1])
    const bDiff = Math.abs(actualPixels[i + 2] - expectedPixels[i + 2])
    const aDiff = Math.abs(actualPixels[i + 3] - expectedPixels[i + 3])

    const isSame =
      rDiff <= threshold &&
      gDiff <= threshold &&
      bDiff <= threshold &&
      aDiff <= threshold

    if (!isSame) {
      differentPixels++
    }

    const value = isSame ? 255 : 0

    diffPixels[i] = value // R
    diffPixels[i + 1] = value // G
    diffPixels[i + 2] = value // B
    diffPixels[i + 3] = 255 // A
  }

  const canvas = document.createElement('canvas')
  canvas.width = width
  canvas.height = height
  const ctx = canvas.getContext('2d')
  if (!ctx) return null

  const diffImageData = new ImageData(diffPixels, width, height)
  ctx.putImageData(diffImageData, 0, 0)

  return { canvas, differentPixels }
}
