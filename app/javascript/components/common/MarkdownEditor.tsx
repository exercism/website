import React, { useCallback } from 'react'
import SimpleMDE from 'react-simplemde-editor'
import { sendPostRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'

export type MarkdownEditorHandle = {
  value: (value: string | void) => string | void
}

export const MarkdownEditor = ({
  contextId,
  onChange = () => {},
  editorDidMount,
  url = document.querySelector<HTMLMetaElement>(
    'meta[name="parse-markdown-url"]'
  )?.content,
  value = '',
}: {
  contextId: string
  url?: string
  editorDidMount?: (editor: MarkdownEditorHandle) => void
  value?: string
  onChange?: (value: string) => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()

  const getInstance = useCallback(
    (editor) => {
      if (!editorDidMount) {
        return
      }

      editorDidMount({ value: editor.value.bind(editor) })
    },
    [editorDidMount]
  )
  return (
    <SimpleMDE
      value={value}
      getMdeInstance={getInstance}
      onChange={onChange}
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

          sendPostRequest({
            endpoint: url,
            body: { markdown: markdown },
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
