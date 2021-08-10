import React, { useState, useCallback } from 'react'
import { Header } from './comments-list/Header'
import { NewCommentForm } from './comments-list/NewCommentForm'
import { Reminder } from './comments-list/Reminder'
import { ListContainer } from './comments-list/ListContainer'
import { ListDisabled } from './comments-list/ListDisabled'
import { Request } from '../../hooks/request-query'
import { Iteration } from '../types'

export type Links = {
  create: string
  changeIteration: string
  unpublish: string
  enable: string
  disable: string
}

export const CommentsList = ({
  defaultAllowComments,
  isAuthor,
  request,
  links,
  iterations,
  publishedIterationIdx,
}: {
  defaultAllowComments: boolean
  isAuthor: boolean
  request: Request
  iterations: readonly Iteration[]
  publishedIterationIdx: number | null
  links: Links
}): JSX.Element => {
  const [allowComments, setAllowComments] = useState(defaultAllowComments)

  const handleCommentsEnabled = useCallback(() => {
    setAllowComments(true)
  }, [])

  const handleCommentsDisabled = useCallback(() => {
    setAllowComments(false)
  }, [])

  return (
    <section className="comments mt-40">
      <Header
        iterations={iterations}
        publishedIterationIdx={publishedIterationIdx}
        links={links}
        isAuthor={isAuthor}
        allowComments={allowComments}
        onCommentsEnabled={handleCommentsEnabled}
        onCommentsDisabled={handleCommentsDisabled}
      />
      <NewCommentForm cacheKey={request.endpoint} endpoint={links.create} />
      <Reminder />
      {allowComments ? (
        <ListContainer cacheKey={request.endpoint} request={request} />
      ) : (
        <ListDisabled isAuthor={isAuthor} />
      )}
    </section>
  )
}
