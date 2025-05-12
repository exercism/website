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

  const iframeHtml = `
    <!DOCTYPE html>
    <html>
      <head>
        <style>${css}</style>
${scriptPrelude}
${js}
} catch (error) {
window.parent.postMessage({
  type: 'iframe-js-error',
  message: error.message,
  stack: error.stack || null,
}, '*');
}
}
</script>
      </head>
      <body>
        ${html}
      </body>
    </html>`

  try {
    iframeDoc.open()
    iframeDoc.write(iframeHtml)
    iframeDoc.close()
  } catch (err) {
    // Catch immediate syntax errors (e.g. unterminated expressions)
    window.postMessage(
      {
        type: 'iframe-js-parse-error',
        message: (err as Error).message,
        stack: (err as Error).stack,
      },
      '*'
    )
    return
  }

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

const scriptPrelude = `<script>
window.onerror = function(message, source, lineno, colno, error) {
window.parent.postMessage({
type: 'iframe-js-error',
message,
source,
lineno,
colno,
stack: error?.stack || null,
}, '*');
};
window.runCode = function() {
try {`

const jsPreludeLines = scriptPrelude.split('\n')
export const jsLineOffset = jsPreludeLines.length
