// import { toCanvas, toSvg, toJpeg } from 'html-to-image/src'
import { toCanvas, toSvg, toJpeg } from 'html-to-image-local/'

export async function getIframePixels(
  iframeRef: React.RefObject<HTMLIFrameElement>
): Promise<Uint8ClampedArray | null> {
  const iframe = iframeRef.current
  if (!iframe) {
    return null
  }

  let pixels: Uint8ClampedArray | null = null

  const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document
  if (!iframeDoc || !iframeDoc.body) {
    return null
  }

  try {
    const canvas = await toCanvas(iframeDoc.body, {
      width: iframe.clientWidth,
      height: iframe.clientHeight,
    })

    // uncomment to generate a download link for the actual canvas content

    // toJpeg(iframeDoc.body, { quality: 1 }).then(function (dataUrl) {
    //   var link = document.createElement('a')
    //   // Generate random name
    //   link.download = `iframe-${Math.random().toString(36).substring(2, 15)}.jpeg`
    //   link.href = dataUrl
    //   link.click()
    // })

    if (canvas) {
      const ctx = canvas.getContext('2d')
      if (ctx) {
        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
        pixels = imageData.data
      }
    }

    return pixels
  } catch (err) {
    console.error('Failed to render iframe to canvas:', err)
    return null
  }
}
