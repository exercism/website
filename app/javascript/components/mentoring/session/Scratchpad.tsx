import React, { useCallback, useState, useEffect, useContext } from 'react'
import { useMutation } from '@tanstack/react-query'
import { camelizeKeys } from 'humps'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { Loading, TrackIcon, AlertTag } from '@/components/common'
import Introducer from '@/components/common/Introducer'
import { default as MarkdownEditor } from '@/components/common/MarkdownEditor'
import type {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
  RepresentationTrack,
  RepresentationExercise,
} from '@/components/types'
import type { Scratchpad as ScratchpadProps } from '../Session'
import { ScreenSizeContext } from './ScreenSizeContext'

type ScratchpadPage = {
  contentMarkdown: string
}

export const Scratchpad = ({
  scratchpad,
  track,
  exercise,
}: {
  scratchpad: ScratchpadProps
  track: Track | RepresentationTrack
  exercise: Exercise | RepresentationExercise
}): JSX.Element => {
  const [content, setContent] = useState('')
  const [error, setError] = useState('')
  const [page, setPage] = useState<ScratchpadPage | null>(null)

  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}

  const handleChange = useCallback((content) => {
    setContent(content)
  }, [])

  const { mutate: mutation } = useMutation<ScratchpadPage>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: scratchpad.links.self,
        method: 'PATCH',
        body: JSON.stringify({
          scratchpad_page: { content_markdown: content },
        }),
      })

      return fetch.then((json) =>
        typecheck<ScratchpadPage>(camelizeKeys(json), 'scratchpadPage')
      )
    },
    {
      onSuccess: (page) => setPage(page),
      onError: (err) => {
        if (err instanceof Response) {
          err.json().then((res: any) => setError(res.error.message))
        }
      },
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      setError('')
      mutation()
    },
    [mutation]
  )

  const pullPage = useCallback(() => {
    const { fetch } = sendRequest({
      endpoint: scratchpad.links.self,
      body: null,
      method: 'GET',
    })

    fetch
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
        // TODO: (required) do something
      })
  }, [scratchpad.links.self])

  useEffect(pullPage, [pullPage])

  const revert = useCallback(() => {
    if (!page) {
      return
    }

    setContent(page.contentMarkdown)
  }, [page])

  useEffect(() => {
    if (!page) {
      return
    }

    setContent(page.contentMarkdown)
  }, [page])

  if (!page) {
    return <Loading />
  }

  return (
    <>
      {scratchpad.isIntroducerHidden ? null : (
        <Introducer
          icon="scratchpad"
          endpoint={scratchpad.links.hideIntroducer}
          size="small"
        >
          <h2>Introducing your scratchpad</h2>
          <p>
            A{' '}
            <a
              target="_blank"
              rel="noreferrer"
              href={scratchpad.links.markdown}
            >
              Markdown-supported
            </a>{' '}
            place for you to write notes and add code snippets you’d like to
            refer to during mentoring.
          </p>
        </Introducer>
      )}
      <div className="flex flex-row justify-between mb-12 items-center">
        <div className="title">
          Your notes for <strong>{exercise.title}</strong> in
          <TrackIcon iconUrl={track.iconUrl} title={track.title} />
          <strong>{track.title}</strong>
        </div>

        <UnsavedWidget
          isBelowLgWidth={isBelowLgWidth}
          isUnchanged={content === page.contentMarkdown}
        />
      </div>

      <form
        data-turbo="false"
        onSubmit={handleSubmit}
        className="c-markdown-editor"
      >
        <MarkdownEditor
          onChange={handleChange}
          contextId={`scratchpad-${scratchpad.links.self}`}
          options={{ status: [] }}
          value={content}
        />
        <footer className="editor-footer scratchpad-footer">
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

function UnsavedWidget({
  isUnchanged,
  isBelowLgWidth,
}: Record<'isUnchanged' | 'isBelowLgWidth', boolean>): JSX.Element | null {
  if (isUnchanged) return null
  if (isBelowLgWidth)
    return (
      <div className="bg-red animate-fadeIn w-[8px] h-[8px] rounded-circle" />
    )
  return <AlertTag>Unsaved</AlertTag>
}
