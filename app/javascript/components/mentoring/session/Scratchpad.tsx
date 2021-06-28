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
import { TrackIcon } from '../../common/TrackIcon'
import { Introducer } from '../../common'
import {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '../../types'
import { Scratchpad as ScratchpadProps } from '../Session'

type ScratchpadPage = {
  contentMarkdown: string
}

export const Scratchpad = ({
  scratchpad,
  track,
  exercise,
}: {
  scratchpad: ScratchpadProps
  track: Track
  exercise: Exercise
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const editorRef = useRef<MarkdownEditorHandle | null>()
  const [content, setContent] = useState('')
  const [error, setError] = useState('')
  const [page, setPage] = useState<ScratchpadPage | null>(null)

  const handleEditorDidMount = useCallback((editor: MarkdownEditorHandle) => {
    editorRef.current = editor

    if (editorRef.current) {
      setContent(editorRef.current.value() || '')
    }
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
        endpoint: scratchpad.links.self,
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
    [isMountedRef, page, scratchpad.links.self]
  )

  const pullPage = useCallback(() => {
    sendRequest({
      endpoint: scratchpad.links.self,
      body: null,
      method: 'GET',
      isMountedRef: isMountedRef,
    })
      .then((json) => {
        const page = typecheck<ScratchpadPage>(
          camelizeKeys(json),
          'scratchpadPage'
        )

        setPage({
          ...page,
          contentMarkdown:
            page.contentMarkdown === null ? '' : page.contentMarkdown,
        })
      })
      .catch(() => {
        // TODO: do something
      })
  }, [isMountedRef, scratchpad.links.self])

  useEffect(pullPage, [pullPage])

  const revert = useCallback(() => {
    if (!editorRef.current || !page) {
      return
    }

    editorRef.current.value(page.contentMarkdown)
  }, [page])

  useEffect(() => {
    if (!editorRef.current || !page) {
      return
    }

    if (editorRef.current.value() !== '') {
      return
    }

    editorRef.current.value(page.contentMarkdown || '')
  }, [page])

  if (!page) {
    return <Loading />
  }

  return (
    <>
      <Introducer
        icon="scratchpad"
        endpoint={scratchpad.links.hideIntroducer}
        hidden={scratchpad.isIntroducerHidden}
      >
        <h3>Introducing your scratchpad</h3>
        <p>
          A <a href={scratchpad.links.markdown}>Markdown-supported</a> place for
          you to write notes and add code snippets you’d like to refer to during
          mentoring.
        </p>
      </Introducer>

      <div className="title">
        Your notes for <strong>{exercise.title}</strong> in
        <TrackIcon iconUrl={track.iconUrl} title={track.title} />
        <strong>Ruby</strong>
      </div>

      <form onSubmit={handleSubmit} className="c-markdown-editor">
        <MarkdownEditor
          editorDidMount={handleEditorDidMount}
          onChange={handleChange}
          contextId={`scratchpad-${scratchpad.links.self}`}
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
              onClick={revert}
            >
              Revert to saved
            </button>
          )}

          <button type="submit" className="btn-primary btn-s">
            Save
          </button>
        </footer>
      </form>
      {error ? <p>{error}</p> : null}
    </>
  )
}
