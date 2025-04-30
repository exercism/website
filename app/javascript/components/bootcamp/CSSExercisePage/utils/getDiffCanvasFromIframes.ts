import { getDiffCanvasFromPixels } from './getDiffCanvasFromPixels'
import { getIframePixels } from './getIframePixels'

export async function getDiffCanvasFromIframes(
  actualIFrameRef: React.RefObject<HTMLIFrameElement>,
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
) {
  const actualPixels = await getIframePixels(actualIFrameRef)
  const expectedPixels = await getIframePixels(expectedIFrameRef)

  if (actualPixels && expectedPixels) {
    const width = actualIFrameRef.current?.clientWidth || 400
    const height = actualIFrameRef.current?.clientHeight || 400
    const canvas = getDiffCanvasFromPixels(
      actualPixels,
      expectedPixels,
      Math.floor(width * window.devicePixelRatio),
      Math.floor(height * window.devicePixelRatio)
    )
    if (canvas) {
      return canvas.canvas
    }
  }
  return null
}
