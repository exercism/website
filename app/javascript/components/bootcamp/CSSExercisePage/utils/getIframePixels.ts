import html2canvas from 'html2canvas'

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
    const canvas = await html2canvas(iframeDoc.body, {
      windowWidth: iframe.clientWidth,
      windowHeight: iframe.clientHeight,
    })

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
