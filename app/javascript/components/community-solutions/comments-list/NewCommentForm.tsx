import React, { useCallback } from 'react'
import { queryCache, QueryKey } from 'react-query'
import { SolutionComment } from '../../types'
import { APIResponse } from './ListContainer'
import { NewListItemForm } from '../../common/NewListItemForm'

const DEFAULT_ERROR = new Error('Unable to post comment')

export const NewCommentForm = ({
  endpoint,
  cacheKey,
}: {
  endpoint: string
  cacheKey: QueryKey
}): JSX.Element => {
  const handleSuccess = useCallback(
    (comment) => {
      const oldData = queryCache.getQueryData<APIResponse>(cacheKey)

      if (!oldData) {
        return [comment]
      }

      queryCache.setQueryData(cacheKey, {
        ...oldData,
        items: [comment, ...oldData.items],
      })
    },
    [cacheKey]
  )

  return (
    <NewListItemForm<SolutionComment>
      endpoint={endpoint}
      expanded
      contextId={endpoint}
      onSuccess={handleSuccess}
      defaultError={DEFAULT_ERROR}
    />
  )
}
