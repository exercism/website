import React, { useState, useCallback } from 'react'
import { MarkdownEditorForm } from '../../common/MarkdownEditorForm'
import { queryCache, QueryKey, useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { SolutionComment } from '../../types'
import { APIResponse } from './ListContainer'

const DEFAULT_ERROR = new Error('Unable to post comment')

export const NewCommentForm = ({
  endpoint,
  cacheKey,
}: {
  endpoint: string
  cacheKey: QueryKey
}): JSX.Element => {
  const [content, setContent] = useState('')

  const [mutation, { status, error }] = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'POST',
        body: JSON.stringify({ content_markdown: content }),
      })

      return fetch.then((response) =>
        typecheck<SolutionComment>(response, 'comment')
      )
    },
    {
      onSuccess: (comment) => {
        const oldData = queryCache.getQueryData<APIResponse>(cacheKey)

        if (!oldData) {
          return
        }

        queryCache.setQueryData(cacheKey, {
          ...oldData,
          comments: [comment, ...oldData.comments],
        })
        setContent('')
      },
    }
  )

  const handleChange = useCallback((value: string) => {
    setContent(value)
  }, [])

  const handleSubmit = useCallback(() => {
    mutation()
  }, [mutation])

  return (
    <MarkdownEditorForm
      expanded
      onChange={handleChange}
      value={content}
      action="new"
      onSubmit={handleSubmit}
      status={status}
      error={error}
      defaultError={DEFAULT_ERROR}
    />
  )
}
