import React, { useState, useCallback } from 'react'
import {
  MentorDiscussion as Discussion,
  Iteration,
  MentorSessionRequest as Request,
} from '../../types'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { useMutation } from 'react-query'
import { MarkdownEditorForm } from '../../common/MarkdownEditorForm'

const DEFAULT_ERROR = new Error('Unable to start discussion')

export const StartDiscussionPanel = ({
  iterations,
  request,
  setDiscussion,
}: {
  iterations: readonly Iteration[]
  request: Request
  setDiscussion: (discussion: Discussion) => void
}): JSX.Element => {
  const contextId = `start-discussion-request-${request.uuid}`
  const [state, setState] = useState({
    expanded: false,
    value: localStorage.getItem(`smde_${contextId}`) || '',
  })
  const lastIteration = iterations[iterations.length - 1]

  const [mutation, { status, error }] = useMutation<Discussion>(
    () => {
      const { fetch } = sendRequest({
        endpoint: request.links.discussion,
        method: 'POST',
        body: JSON.stringify({
          mentor_request_uuid: request.uuid,
          content: state.value,
          iteration_idx: lastIteration.idx,
        }),
      })

      return fetch.then((json) => typecheck<Discussion>(json, 'discussion'))
    },
    {
      onSuccess: (discussion) => setDiscussion(discussion),
    }
  )

  const handleSubmit = useCallback(() => {
    mutation()
  }, [mutation])

  const handleClick = useCallback(() => {
    if (state.expanded) {
      return
    }

    setState({ ...state, expanded: true })
  }, [state])

  const handleCancel = useCallback(() => {
    setState({ ...state, expanded: false })
  }, [state])

  const handleChange = useCallback(
    (value: string) => {
      setState({ ...state, value: value })
    },
    [state]
  )

  return (
    <section className="comment-section --comment">
      <MarkdownEditorForm
        onSubmit={handleSubmit}
        onClick={handleClick}
        onCancel={handleCancel}
        onChange={handleChange}
        contextId={contextId}
        value={state.value}
        expanded={state.expanded}
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
        action="new"
      />
      {/* TODO: (optional) Extract into common component with the other identical notes in app/javascript/components/mentoring/discussion/AddDiscussionPost.tsx */}
      <div className="note">
        Check out our {/* TODO: (required) */}
        <a href="#">mentoring docs</a> and be the best mentor you can be.
      </div>
    </section>
  )
}
