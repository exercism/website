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

window.onunhandledrejection = function(event) {
  window.parent.postMessage({
    type: 'iframe-js-error',
    message: event.reason?.message || String(event.reason),
    stack: event.reason?.stack || null,
  }, '*');
};

window.fetchObject = function (url, options, onFulfil, onReject) {
  fetch(url, options)
    .then(r => r.json())
    .then((json) => onFulfil(json))
    .catch(onReject)
}

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
    runId: window.__runId__,
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
// +1 offset because this line got added to the prelude:
// window.__runId__ = ${jsCodeRunId};
export const jsLineOffset = jsPreludeLines.length + 1

export function updateIFrame(
  iframeRef:
    | React.RefObject<HTMLIFrameElement>
    | React.ForwardedRef<HTMLIFrameElement>,
  { html, css, script }: { html?: string; css?: string; script?: string },
  code: FrontendExercisePageCode
): void {
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

  try {
    iframeElement.onload = () => {
      try {
        const runCode = (
          iframeElement.contentWindow as Window & { runCode?: () => void }
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
  }
}
