export function updateIFrame(
  iframeRef:
    | React.RefObject<HTMLIFrameElement>
    | React.ForwardedRef<HTMLIFrameElement>,
  { html, css }: { html?: string; css?: string },
  code: CSSExercisePageCode
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
        body{
          background: white;
        }
        ${code.normalizeCss}
        ${code.default.css}
        ${css}
        </style>
      </head>
      <body style="aspect-ratio:${code.aspectRatio}">
        ${html}
        </body>
        </html>
        `)
  iframeDoc.close()
}
