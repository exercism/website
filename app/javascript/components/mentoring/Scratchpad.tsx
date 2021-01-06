import React, { useCallback, useState, useRef, useEffect } from 'react'
import { MarkdownEditor, MarkdownEditorHandle } from '../common/MarkdownEditor'
import { sendRequest } from '../../utils/send-request'
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
  const [error, setError] = useState('')
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

      if (!editorRef.current || !page) {
        return
      }

      setError('')

      sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({
          scratchpad_page: { content_markdown: editorRef.current?.value() },
        }),
        isMountedRef: isMountedRef,
      })
        .then((json: any) => {
          if (!json) {
            return
          }

          setPage(
            typecheck<ScratchpadPage>(camelizeKeys(json), 'scratchpadPage')
          )
        })
        .catch((err) => {
          if (err instanceof Response) {
            err.json().then((res: any) => setError(res.error.message))
          }
        })
    },
    [endpoint, isMountedRef, page]
  )

  const pullPage = useCallback(() => {
    sendRequest({
      endpoint: endpoint,
      body: null,
      method: 'GET',
      isMountedRef: isMountedRef,
    })
      .then((json) => {
        setPage(typecheck<ScratchpadPage>(camelizeKeys(json), 'scratchpadPage'))
      })
      .catch(() => {
        // TODO: do something
      })
  }, [endpoint, isMountedRef])

  useEffect(pullPage, [pullPage])

  useEffect(() => {
    if (!editorRef.current || !page) {
      return
    }

    editorRef.current.value(page.contentMarkdown || '')
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
          options={{ status: [] }}
        />
        <button type="submit">Save</button>
      </form>
      <button type="button" onClick={() => pullPage()}>
        Revert
      </button>
      {content === page.contentMarkdown ? null : <p>Unsaved</p>}
      {error ? <p>{error}</p> : null}
    </div>
  )
}
