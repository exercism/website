import React, { useState, useCallback } from 'react'
import { Header } from './comments-list/Header'
import { NewCommentForm } from './comments-list/NewCommentForm'
import { Reminder } from './comments-list/Reminder'
import { ListContainer } from './comments-list/ListContainer'
import { ListDisabled } from './comments-list/ListDisabled'
import { Request } from '../../hooks/request-query'

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
  isGuest,
  request,
  links,
}: {
  defaultAllowComments: boolean
  isAuthor: boolean
  isGuest: boolean
  request: Request
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
        links={links}
        isAuthor={isAuthor}
        isGuest={isGuest}
        allowComments={allowComments}
        onCommentsEnabled={handleCommentsEnabled}
        onCommentsDisabled={handleCommentsDisabled}
      />
      {allowComments && !isGuest ? (
        <React.Fragment>
          <NewCommentForm cacheKey={request.endpoint} endpoint={links.create} />
          <Reminder />
        </React.Fragment>
      ) : null}
      {allowComments ? (
        <ListContainer cacheKey={request.endpoint} request={request} />
      ) : (
        <ListDisabled isAuthor={isAuthor} />
      )}
    </section>
  )
}
