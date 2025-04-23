import { getIframePixels } from './getIframePixels'
import { getPixelsMatchPercentage } from './getPixelsMatchPercentage'
import { getPixelsMatchPercentageWithDiffCanvas } from './getPixelsMatchPercentageWithDiffCanvas'

export async function getIframesMatchPercentage(
  actualIFrameRef: React.RefObject<HTMLIFrameElement>,
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
): Promise<any> {
  const actualPixels = await getIframePixels(actualIFrameRef)
  const expectedPixels = await getIframePixels(expectedIFrameRef)

  return {
    percentage: getPixelsMatchPercentage(actualPixels, expectedPixels),
    //   alternative: getPixelsMatchPercentageWithDiffCanvas(
    //     actualPixels,
    //     expectedPixels,
    //     350,
    //     350
    //   ),
  }
}
