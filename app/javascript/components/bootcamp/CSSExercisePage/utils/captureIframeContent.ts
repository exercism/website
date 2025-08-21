import { toPixelData } from '@exercism/html-to-image'

export async function captureIframeContent(
  iframeRef: React.RefObject<HTMLIFrameElement>
): Promise<Uint8ClampedArray | null> {
  if (!iframeRef.current) return null

  const iframe = iframeRef.current
  const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document
  if (!iframeDoc || !iframeDoc.body) return null

  try {
    return await toPixelData(iframeDoc.body)
  } catch (error) {
    console.error('Error capturing iframe content:', error)
    return null
  }
}
