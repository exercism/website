import { captureIframeContent } from './captureIframeContent'

export async function getIframesMatchPercentage(
  actualIFrameRef: React.RefObject<HTMLIFrameElement>,
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
): Promise<number> {
  const actualPixels = await captureIframeContent(actualIFrameRef)
  const expectedPixels = await captureIframeContent(expectedIFrameRef)

  if (!actualPixels || !expectedPixels) return 0

  if (actualPixels.length !== expectedPixels.length) return 0

  let differentPixels = 0
  const totalPixels = actualPixels.length / 4

  for (let i = 0; i < actualPixels.length; i += 4) {
    const rDiff = Math.abs(actualPixels[i] - expectedPixels[i])
    const gDiff = Math.abs(actualPixels[i + 1] - expectedPixels[i + 1])
    const bDiff = Math.abs(actualPixels[i + 2] - expectedPixels[i + 2])
    const aDiff = Math.abs(actualPixels[i + 3] - expectedPixels[i + 3])

    const threshold = 10
    if (
      rDiff > threshold ||
      gDiff > threshold ||
      bDiff > threshold ||
      aDiff > threshold
    ) {
      differentPixels++
    }
  }

  console.log('differentPixels', differentPixels)

  const matchPercentage = ((1 - differentPixels / totalPixels) * 100).toFixed(2)
  return parseFloat(matchPercentage)
}
