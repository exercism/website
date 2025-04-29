import { getDiffCanvas } from './getDiffCanvas'
import { getIframePixels } from './getIframePixels'
import { getPixelsMatchPercentage } from './getPixelsMatchPercentage'

export async function getIframesMatchPercentage(
  actualIFrameRef: React.RefObject<HTMLIFrameElement>,
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
): Promise<number> {
  const actualPixels = await getIframePixels(actualIFrameRef)
  const expectedPixels = await getIframePixels(expectedIFrameRef)

  console.log('actualpx', actualPixels?.length, expectedPixels?.length)

  // const width = 100
  // const height = 100
  // const dummyPixels = new Uint8ClampedArray(width * height * 4)

  // // Fill with white first
  // for (let i = 0; i < dummyPixels.length; i += 4) {
  //   dummyPixels[i] = 255 // R
  //   dummyPixels[i + 1] = 255 // G
  //   dummyPixels[i + 2] = 255 // B
  //   dummyPixels[i + 3] = 255 // A
  // }

  // // Draw a black diagonal
  // for (let y = 0; y < height; y++) {
  //   const x = y // For diagonal
  //   const index = (y * width + x) * 4
  //   dummyPixels[index] = 0 // R
  //   dummyPixels[index + 1] = 0 // G
  //   dummyPixels[index + 2] = 0 // B
  //   dummyPixels[index + 3] = 255 // A
  // }

  // const dummyCanvas = document.createElement('canvas')
  // dummyCanvas.width = width
  // dummyCanvas.height = height
  // const ctx = dummyCanvas.getContext('2d')

  // if (ctx) {
  //   const imageData = new ImageData(dummyPixels, width, height)
  //   ctx.putImageData(imageData, 0, 0)
  //   document.body.appendChild(dummyCanvas)
  // }

  if (actualPixels && expectedPixels) {
    const canvas = getDiffCanvas(
      actualPixels,
      expectedPixels,
      actualIFrameRef.current?.clientWidth || 400,
      actualIFrameRef.current?.clientHeight || 400
    )
    if (canvas) {
      console.log('canvas diff', canvas.differentPixels)
      const diffCanvas = canvas.canvas
      diffCanvas.id = 'diff-canvas'
      diffCanvas.style.position = 'absolute'
      diffCanvas.style.top = '0'
      diffCanvas.style.left = '0'
      document.body.appendChild(diffCanvas)
    }
  }

  return getPixelsMatchPercentage(actualPixels, expectedPixels)
}
