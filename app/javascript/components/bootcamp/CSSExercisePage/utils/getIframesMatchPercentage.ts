import { getIframePixels } from './getIframePixels'
import { getPixelsMatchPercentage } from './getPixelsMatchPercentage'

export async function getIframesMatchPercentage(
  actualIFrameRef: React.RefObject<HTMLIFrameElement>,
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
): Promise<number> {
  const actualPixels = await getIframePixels(actualIFrameRef)
  const expectedPixels = await getIframePixels(expectedIFrameRef)

  return getPixelsMatchPercentage(actualPixels, expectedPixels)
}
