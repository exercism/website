import React, { useCallback, useContext, useMemo, useState } from 'react'
import { sendRequest } from '../../../utils/send-request'
import { useMutation, queryCache } from 'react-query'
import { PostsContext } from './PostsContext'
import { DiscussionPostProps } from './DiscussionPost'
import { typecheck } from '../../../utils/typecheck'
import { MarkdownEditorForm } from '../../common/MarkdownEditorForm'
import { MentorDiscussion } from '../../types'

const DEFAULT_ERROR = new Error('Unable to save post')

export const AddDiscussionPostForm = ({
  discussion,
  onSuccess,
}: {
  discussion: MentorDiscussion
  onSuccess: () => void
}): JSX.Element => {
  const contextId = useMemo(() => `${discussion.uuid}_new_post`, [discussion])
  const [state, setState] = useState({
    expanded: false,
    value: localStorage.getItem(`smde_${contextId}`) || '',
  })
  const { cacheKey } = useContext(PostsContext)
  const handleSuccess = useCallback(() => {
    setState({ value: '', expanded: false })
    onSuccess()
  }, [onSuccess])
  const [mutation, { status, error }] = useMutation<DiscussionPostProps>(
    () => {
      const { fetch } = sendRequest({
        endpoint: discussion.links.posts,
        method: 'POST',
        body: JSON.stringify({ content: state.value }),
      })

      return fetch.then((json) => typecheck<DiscussionPostProps>(json, 'post'))
    },
    {
      onSettled: () => queryCache.invalidateQueries(cacheKey),
      onSuccess: handleSuccess,
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
  )
}
