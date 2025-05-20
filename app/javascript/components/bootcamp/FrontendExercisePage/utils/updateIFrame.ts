export const scriptPrelude = `window.onerror = function(message, source, lineno, colno, error) {
  window.parent.postMessage({
    type: 'iframe-js-error',
    message,
    source,
    lineno,
    colno,
    stack: error?.stack || null,
  }, '*');
};

window.log = function(...args) {
  window.parent.postMessage({
    type: 'iframe-log',
    logs: [args],
  }, '*');
};

window.runCode = function() {
  try {
`

export const scriptPostlude = `
  } catch (error) {
    window.parent.postMessage({
      type: 'iframe-js-error',
      message: error.message,
      stack: error.stack || null,
    }, '*');
  }
};
`

const jsPreludeLines = scriptPrelude.split('\n')
export const jsLineOffset = jsPreludeLines.length

export function updateIFrame(
  iframeRef:
    | React.RefObject<HTMLIFrameElement>
    | React.ForwardedRef<HTMLIFrameElement>,
  { html, css, script }: { html?: string; css?: string; script?: string },
  code: FrontendExercisePageCode
): (() => void) | undefined {
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
        <style>
        ${code.normalizeCss}
        ${code.default.css} 
        ${css || ''}
        </style>
        </head>
        <body>
        ${html || ''}
        ${script || ''}
      </body>
    </html>`

  try {
    iframeDoc.open()
    iframeDoc.write(iframeHtml)
    iframeDoc.close()
  } catch (err) {
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

  return () => {
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
