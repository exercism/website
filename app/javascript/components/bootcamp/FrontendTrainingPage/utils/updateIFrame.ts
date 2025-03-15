export function updateIFrame(
  iFrameRef:
    | React.RefObject<HTMLIFrameElement>
    | React.ForwardedRef<HTMLIFrameElement>,
  html: string,
  css: string
) {
  let iframeElement: HTMLIFrameElement | null = null

  if (iFrameRef) {
    if (typeof iFrameRef === 'function') {
      console.warn('Function refs are not supported in updateIFrame')
      return
    } else if ('current' in iFrameRef) {
      iframeElement = iFrameRef.current
    }
  }

  if (!iframeElement) return

  const iframeDoc =
    iframeElement.contentDocument || iframeElement.contentWindow?.document
  if (!iframeDoc) return

  iframeDoc.open()
  iframeDoc.write(`
    <!DOCTYPE html>
    <html>
      <head>
        <style>${css}</style>
      </head>
      <body>${html}</body>
    </html>
  `)
  iframeDoc.close()
}
