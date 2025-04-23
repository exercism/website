export function updateIFrame(
  iframeRef:
    | React.RefObject<HTMLIFrameElement>
    | React.ForwardedRef<HTMLIFrameElement>,
  { html, css }: { html?: string; css?: string },
  defaults: { html?: string; css?: string } = { html: '', css: '' }
) {
  let iframeElement: HTMLIFrameElement | null = null

  if (iframeRef) {
    if (typeof iframeRef === 'function') {
      console.warn('Function refs are not supported in updateIFrame')
      return
    } else if ('current' in iframeRef) {
      iframeElement = iframeRef.current
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
        <style>
        ${defaults.css}
        ${css}
        </style>
      </head>
      <body>
        ${html}
        </body>
        </html>
        `)
  iframeDoc.close()
}
