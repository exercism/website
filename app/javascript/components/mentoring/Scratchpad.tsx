import React, { useCallback, useState, useRef, useEffect } from 'react'
import { MarkdownEditor, MarkdownEditorHandle } from '../common/MarkdownEditor'
import { sendPostRequest, sendRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../utils/typecheck'
import { camelizeKeys } from 'humps'
import { Loading } from '../common/Loading'

type ScratchpadPage = {
  contentMarkdown: string
}

export const Scratchpad = ({
  endpoint,
  discussionId,
}: {
  endpoint: string
  discussionId: number
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const editorRef = useRef<MarkdownEditorHandle | null>()
  const [content, setContent] = useState('')
  const [page, setPage] = useState<ScratchpadPage | null>(null)

  const handleEditorDidMount = useCallback((editor: MarkdownEditorHandle) => {
    editorRef.current = editor
  }, [])

  const handleChange = useCallback((content) => {
    setContent(content)
  }, [])

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      if (!editorRef.current) {
        return
      }

      sendPostRequest({
        endpoint: endpoint,
        body: { content_markdown: editorRef.current?.value() },
        isMountedRef: isMountedRef,
      }).then((json: any) => {
        if (!json) {
          return
        }

        setPage(typecheck<ScratchpadPage>(camelizeKeys(json), 'scratchpadPage'))
      })
    },
    [endpoint, isMountedRef]
  )

  useEffect(() => {
    sendRequest({
      endpoint: endpoint,
      body: null,
      method: 'GET',
      isMountedRef: isMountedRef,
    }).then((json) => {
      if (!json) {
        return setPage({ contentMarkdown: '' })
      }

      setPage(typecheck<ScratchpadPage>(camelizeKeys(json), 'scratchpadPage'))
    })
  }, [endpoint, isMountedRef])

  useEffect(() => {
    if (!editorRef.current || !page) {
      return
    }

    editorRef.current.value(page.contentMarkdown)
  }, [page])

  if (!page) {
    return <Loading />
  }

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <MarkdownEditor
          editorDidMount={handleEditorDidMount}
          onChange={handleChange}
          contextId={`scratchpad-${discussionId}`}
        />
        <button type="submit">Save</button>
      </form>
      {content === page.contentMarkdown ? null : <p>Unsaved</p>}
    </div>
  )
}
