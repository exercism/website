import React from 'react'
import SimpleMDE from 'react-simplemde-editor'
import { sendRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'

export const MarkdownEditor = ({
  contextId,
  url = document.querySelector<HTMLMetaElement>(
    'meta[name="parse-markdown-url"]'
  )?.content,
}: {
  contextId: string
  url?: string
}): JSX.Element => {
  const isMountedRef = useIsMounted()

  return (
    <SimpleMDE
      options={{
        autosave: { enabled: true, uniqueId: contextId },
        blockStyles: {
          italic: '_',
        },
        indentWithTabs: false,
        toolbar: [
          'heading',
          'bold',
          'italic',
          'code',
          'link',
          'unordered-list',
          'ordered-list',
          'fullscreen',
          'preview',
        ],
        status: ['autosave'],
        previewRender: (markdown, preview) => {
          if (!url) {
            return 'Preview unavailable'
          }

          sendRequest({
            endpoint: url,
            body: JSON.stringify({ markdown: markdown }),
            method: 'POST',
            isMountedRef: isMountedRef,
          })
            .then((json: any) => {
              preview.innerHTML = json.html
            })
            .catch(() => {
              preview.innerHTML = '<p>Unable to parse markdown</p>'
            })

          return 'Loading...'
        },
      }}
    />
  )
}
