// i18n-key-prefix:
// i18n-namespace: components/common/MarkdownEditor.tsx
import React, { useCallback, useContext, useMemo } from 'react'
import SimpleMDE, { SimpleMDEReactProps } from 'react-simplemde-editor'
import { useDeepMemo } from '@/hooks/use-deep-memo'
import { sendRequest } from '@/utils/send-request'
import { ScreenSizeContext } from '../mentoring/session/ScreenSizeContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type MarkdownEditorHandle = {
  value: (value: string | void) => string | void
  focus: () => void
}

export default function MarkdownEditor({
  contextId,
  onChange = () => null,
  editorDidMount,
  url = document.querySelector<HTMLMetaElement>(
    'meta[name="parse-markdown-url"]'
  )?.content,
  defaultValue = '',
  value = '',
  options = {},
}: {
  contextId?: string
  url?: string
  editorDidMount?: (editor: MarkdownEditorHandle) => void
  defaultValue?: string
  value?: string
  onChange?: (value: string) => void
  options?: EasyMDE.Options
}): JSX.Element {
  const { t } = useAppTranslation('components/common/MarkdownEditor.tsx')
  const getInstance = useCallback(
    (editor) => {
      if (!editorDidMount) {
        return
      }

      // Ensure that the HOME and END keys make the cursor go to the
      // beginning/end of the same line on which the cursor is placed
      editor.codemirror.addKeyMap({
        Home: 'goLineLeft',
        End: 'goLineRight',
      })

      editorDidMount({
        value: editor.value.bind(editor),
        focus: () => {
          editor.codemirror.focus()
          editor.codemirror.setCursor(editor.codemirror.lineCount(), 0)
        },
      })
    },
    [editorDidMount]
  )

  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}
  options = useDeepMemo(options)

  const editorOptions = useMemo<SimpleMDEReactProps['options']>(() => {
    return {
      autosave: contextId
        ? { enabled: true, uniqueId: contextId, delay: 1000 }
        : undefined,
      autoRefresh: true,
      blockStyles: {
        italic: '_',
      },
      indentWithTabs: false,
      toolbar: isBelowLgWidth
        ? ['preview']
        : [
            'heading',
            'bold',
            'italic',
            'quote',
            'code',
            'link',
            'unordered-list',
            'ordered-list',
            'preview',
          ],
      status: ['autosave'],
      previewRender: (markdown, preview) => {
        if (!url) {
          return t('previewUnavailable')
        }

        const { fetch } = sendRequest<{ html: string }>({
          endpoint: url,
          method: 'POST',
          body: JSON.stringify({
            parse_options: {
              strip_h1: false,
              lower_heading_levels_by: 2,
            },
            markdown: markdown,
          }),
        })

        fetch
          .then((response) => {
            preview.innerHTML = `<div class="c-textual-content --small">${response.html}</div>`
          })
          .catch(() => {
            preview.innerHTML = `<p>${t('unableToParseMarkdown')}</p>`
          })

        return t('loading')
      },
      ...options,
    }
  }, [contextId, options, url, isBelowLgWidth, t])

  return (
    <SimpleMDE
      value={value}
      defaultValue={defaultValue}
      getMdeInstance={getInstance}
      onChange={onChange}
      options={editorOptions}
    />
  )
}
