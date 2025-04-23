export function getPixelsMatchPercentageWithDiffCanvas(
  actualPixels: Uint8ClampedArray | null,
  expectedPixels: Uint8ClampedArray | null,
  width: number,
  height: number
): { percentage: number; diffCanvas: HTMLCanvasElement | null } {
  if (!actualPixels || !expectedPixels)
    return { percentage: 0, diffCanvas: null }
  if (actualPixels.length !== expectedPixels.length)
    return { percentage: 0, diffCanvas: null }

  const diffCanvas = document.createElement('canvas')
  diffCanvas.width = width
  diffCanvas.height = height

  const ctx = diffCanvas.getContext('2d')
  if (!ctx) return { percentage: 0, diffCanvas: null }

  const diffImageData = ctx.createImageData(width, height)
  const diffData = diffImageData.data

  let differentPixels = 0
  const totalPixels = actualPixels.length / 4

  for (let i = 0; i < actualPixels.length; i += 4) {
    const rDiff = Math.abs(actualPixels[i] - expectedPixels[i])
    const gDiff = Math.abs(actualPixels[i + 1] - expectedPixels[i + 1])
    const bDiff = Math.abs(actualPixels[i + 2] - expectedPixels[i + 2])
    const aDiff = Math.abs(actualPixels[i + 3] - expectedPixels[i + 3])

    const threshold = 0
    const isDifferent =
      rDiff > threshold ||
      gDiff > threshold ||
      bDiff > threshold ||
      aDiff > threshold

    if (isDifferent) {
      differentPixels++

      diffData[i] = 255
      diffData[i + 1] = 0
      diffData[i + 2] = 0
      diffData[i + 3] = 255
    } else {
      diffData[i] = 0
      diffData[i + 1] = 0
      diffData[i + 2] = 0
      diffData[i + 3] = 0
    }
  }

  ctx.putImageData(diffImageData, 0, 0)

  const percentage = parseFloat(
    ((1 - differentPixels / totalPixels) * 100).toFixed(2)
  )

  return { percentage, diffCanvas }
}
