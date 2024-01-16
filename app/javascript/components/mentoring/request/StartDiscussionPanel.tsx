import React, { useState, useCallback } from 'react'
import {
  MentorDiscussion as Discussion,
  Iteration,
  MentorSessionRequest as Request,
} from '../../types'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { useMutation } from '@tanstack/react-query'
import { MarkdownEditorForm } from '../../common/MarkdownEditorForm'
import { redirectTo } from '../../../utils/redirect-to'
import { LockedSolutionMentoringNote } from './locked-solution-mentoring-note/LockedSolutionMentoringNote'

const DEFAULT_ERROR = new Error('Unable to start discussion')

type Links = {
  mentoringDocs: string
}

export const StartDiscussionPanel = ({
  iterations,
  request,
  defaultExpanded,
  links,
}: {
  iterations: readonly Iteration[]
  request: Request
  defaultExpanded: boolean
  links: Links
}): JSX.Element => {
  const contextId = `start-discussion-request-${request.uuid}`
  const [state, setState] = useState({
    expanded: defaultExpanded,
    value: localStorage.getItem(`smde_${contextId}`) || '',
  })
  const lastIteration = iterations[iterations.length - 1]

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<Discussion>(
    async () => {
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
      onSuccess: (discussion) => redirectTo(discussion.links.self),
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
      <LockedSolutionMentoringNote links={links} request={request} />
    </section>
  )
}
