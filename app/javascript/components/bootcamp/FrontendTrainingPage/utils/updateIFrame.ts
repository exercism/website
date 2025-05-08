export function updateIFrame(
  iframeRef:
    | React.RefObject<HTMLIFrameElement>
    | React.ForwardedRef<HTMLIFrameElement>,
  { html, css, js }: { html?: string; css?: string; js?: string },
  code?: FrontendExercisePageCode
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
        <style>${css}</style>
        <script>
          window.runCode = function() {
            try {
              ${js}
            } catch (error) {
              console.error('User script error:', error)
            }
          }
        </script>
      </head>
      <body>
        ${html}
        </body>
        </html>
        `)
  iframeDoc.close()

  iframeElement.onload = () => {
    try {
      // @ts-ignore
      const runCode = iframeElement?.contentWindow?.runCode
      if (typeof runCode === 'function') {
        runCode()
      } else {
        console.warn('runCode is not defined on iframe')
      }
    } catch (err) {
      console.error('Failed to execute runCode:', err)
    }
  }
}

/* <script>window.runCode?.()</script> */
