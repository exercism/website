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

window.log = function (...args) {
  function sanitize(value) {
    if (value instanceof HTMLCollection || value instanceof NodeList) {
      return Array.from(value).map(sanitize);
    }
    if (value instanceof Element) {
      return value.outerHTML;
    }
    if (Array.isArray(value)) {
      return value.map(sanitize);
    }
    if (value && typeof value === 'object') {
      const safeObj = {};
      for (const key in value) {
        safeObj[key] = sanitize(value[key]);
      }
      return safeObj;
    }
    return value;
  }

  const safeArgs = args.map(sanitize);

  window.parent.postMessage({
    type: 'iframe-log',
    logs: [safeArgs],
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

  let iframeLoaded = false

  try {
    iframeElement.onload = () => {
      iframeLoaded = true
    }
    iframeElement.srcdoc = iframeHtml
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
    if (!iframeLoaded) {
      console.warn('iframe not ready yet — retrying shortly')
      setTimeout(() => {
        const runCode = (
          iframeElement?.contentWindow as Window & { runCode?: () => void }
        )?.runCode
        if (typeof runCode === 'function') {
          runCode()
        }
      }, 50)
      return
    }

    try {
      const runCode = (
        iframeElement?.contentWindow as Window & { runCode?: () => void }
      )?.runCode
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
