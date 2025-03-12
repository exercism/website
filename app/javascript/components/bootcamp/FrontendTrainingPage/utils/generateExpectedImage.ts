import { toPixelData } from 'html-to-image'

export async function generateExpectedImage(
  iframeRef: React.RefObject<HTMLIFrameElement>,
  imageRef: React.RefObject<HTMLImageElement>
): Promise<void | null> {
  if (!iframeRef.current) return null

  const iframe = iframeRef.current
  const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document
  if (!iframeDoc || !iframeDoc.body) return null

  console.log('IFRAME BODY', iframeDoc.body.getBoundingClientRect())
  const actualWidth = Math.round(iframeDoc.body.getBoundingClientRect().width)
  const actualHeight = Math.round(iframeDoc.body.getBoundingClientRect().height)

  console.log('Actual iframe content size:', actualWidth, actualHeight)

  try {
    const pixelData = await toPixelData(iframeDoc.body)

    console.log(
      'Pixel data length:',
      pixelData.length,
      'Expected:',
      actualWidth * actualHeight * 4
    )

    const expectedLength = actualWidth * actualHeight * 4
    if (pixelData.length !== expectedLength) {
      console.error(
        `Pixel data length mismatch! Expected ${expectedLength}, but got ${pixelData.length}`
      )
      return null
    }

    const canvas = document.createElement('canvas')
    canvas.width = 350
    canvas.height = 350

    const ctx = canvas.getContext('2d')
    if (!ctx) throw new Error('CanvasRenderingContext2D not supported')

    const imageData = new ImageData(pixelData, actualWidth, actualHeight)
    ctx.putImageData(imageData, 0, 0)

    if (imageRef.current) {
      imageRef.current.src = canvas.toDataURL()
    }
  } catch (error) {
    console.error('Error capturing iframe content:', error)
  }
}
