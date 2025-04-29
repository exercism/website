import { getDiffCanvasFromPixels } from './getDiffCanvasFromPixels'
import { getIframePixels } from './getIframePixels'

export async function getDiffCanvasFromIframes(
  actualIFrameRef: React.RefObject<HTMLIFrameElement>,
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
) {
  const actualPixels = await getIframePixels(actualIFrameRef)
  const expectedPixels = await getIframePixels(expectedIFrameRef)

  if (actualPixels && expectedPixels) {
    const canvas = getDiffCanvasFromPixels(
      actualPixels,
      expectedPixels,
      actualIFrameRef.current?.clientWidth || 400,
      actualIFrameRef.current?.clientHeight || 400
    )
    if (canvas) {
      return canvas.canvas
    }
  }
  return null
}
