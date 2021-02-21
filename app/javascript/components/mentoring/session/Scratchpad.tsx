import React, { useCallback, useState, useRef, useEffect } from 'react'
import {
  MarkdownEditor,
  MarkdownEditorHandle,
} from '../../common/MarkdownEditor'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../utils/typecheck'
import { camelizeKeys } from 'humps'
import { Loading } from '../../common/Loading'
import { Icon } from '../../common/Icon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { TrackIcon } from '../../common/TrackIcon'

type ScratchpadPage = {
  contentMarkdown: string
}

export const Scratchpad = ({ endpoint }: { endpoint: string }): JSX.Element => {
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
    <>
      <div className="c-explainer">
        <GraphicalIcon icon="graphic-scratchpad" />
        <div className="--content">
          <h3>Introducing your scratchpad</h3>
          <p>
            A <a href="#">Markdown-supported</a> place for you to write notes
            and add code snippets you’d like to refer to during mentoring.
          </p>
        </div>
        <button>
          <Icon icon="cross" alt="Remove this explainer section" />
        </button>
      </div>

      <div className="title">
        {/* TODO: Add real exercise/track for this */}
        Your notes for <strong>Hamming</strong> in
        <TrackIcon
          iconUrl="https://assets.exercism.io/tracks/ruby-hex-white.png"
          title="Ruby"
        />
        <strong>Ruby</strong>
      </div>

      <form onSubmit={handleSubmit} className="c-markdown-editor">
        <MarkdownEditor
          editorDidMount={handleEditorDidMount}
          onChange={handleChange}
          contextId={`scratchpad-${endpoint}`}
          options={{ status: [] }}
        />
        <footer className="editor-footer">
          {content === page.contentMarkdown ? null : (
            <div className="--warning">Unsaved</div>
          )}

          {content === page.contentMarkdown ? null : (
            <button
              className="btn-small-discourage"
              type="button"
              onClick={() => pullPage()}
            >
              Revert to saved
            </button>
          )}

          <button type="submit" className="btn-small-cta">
            Save
          </button>
        </footer>
      </form>
      {error ? <p>{error}</p> : null}
    </>
  )
}
