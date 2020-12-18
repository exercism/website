import React from 'react'
import SimpleMDE from 'react-simplemde-editor'
import 'easymde/dist/easymde.min.css'
import { sendRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'

export const MarkdownEditor = ({ uuid }: { uuid: string }): JSX.Element => {
  const isMountedRef = useIsMounted()
  const url = document.querySelector<HTMLMetaElement>(
    'meta[name="parse-markdown-url"]'
  )?.content

  return (
    <SimpleMDE
      options={{
        autosave: { enabled: true, uniqueId: uuid },
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
          }).then((json: any) => {
            preview.innerHTML = json.html
          })

          return 'Loading...'
        },
      }}
    />
  )
}
