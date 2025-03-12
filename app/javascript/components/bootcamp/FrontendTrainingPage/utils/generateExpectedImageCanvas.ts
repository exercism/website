import { toCanvas } from 'html-to-image'

export async function generateExpectedImageCanvas(
  iframeRef: React.RefObject<HTMLIFrameElement>,
  canvasContainerRef: React.RefObject<HTMLDivElement>
): Promise<void | null> {
  if (!iframeRef.current) return null

  const iframe = iframeRef.current
  const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document
  const target = iframeDoc?.getElementById('asdf')
  if (!target || !iframeDoc) return null
  const width = target.getBoundingClientRect().width
  const height = target.getBoundingClientRect().height
  console.log('width', width)
  console.log('height', height)

  try {
    const canvas = await toCanvas(iframeDoc.body, {
      canvasWidth: width,
      canvasHeight: height,
      width,
      height,
      quality: 1,
      pixelRatio: 1,
    })
    console.log('canvas', canvas)
    if (canvasContainerRef.current) {
      canvasContainerRef.current.appendChild(canvas)
    }
  } catch (error) {
    console.error('Error capturing iframe content:', error)
  }
}
