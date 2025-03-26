export function updateIFrame(
  iFrameRef:
    | React.RefObject<HTMLIFrameElement>
    | React.ForwardedRef<HTMLIFrameElement>,
  {
    html,
    css,
    javascript,
  }: { html?: string; css?: string; javascript?: string }
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

  const existingHtml = iframeDoc.body?.innerHTML || ''
  const existingCss = iframeDoc.head?.querySelector('style')?.textContent || ''
  const existingJs = iframeDoc.head?.querySelector('script')?.textContent || ''

  const finalHtml = html ?? existingHtml
  const finalCss = css ?? existingCss
  const finalJs = javascript ?? existingJs

  iframeDoc.open()
  iframeDoc.write(`
    <!DOCTYPE html>
    <html>
      <head>
        <style>${finalCss}</style>
        <script>
          window.runCode = function() {
            try {
              ${finalJs}
            } catch (error) {
              console.error('User script error:', error)
            }
          }
        </script>
      </head>
      <body>
        ${finalHtml}
        <script>window.runCode?.()</script>
      </body>
    </html>
  `)
  iframeDoc.close()
}
