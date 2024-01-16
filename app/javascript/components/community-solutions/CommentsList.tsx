import React, { useState, useCallback } from 'react'
import { Header } from './comments-list/Header'
import { NewCommentForm } from './comments-list/NewCommentForm'
import { Reminder } from './comments-list/Reminder'
import { ListContainer } from './comments-list/ListContainer'
import { ListDisabled } from './comments-list/ListDisabled'
import type { Request } from '@/hooks/request-query'

export type Links = {
  create: string
  changeIteration: string
  unpublish: string
  enable: string
  disable: string
}

export default function CommentsList({
  defaultAllowComments,
  isAuthor,
  userSignedIn,
  request,
  links,
}: {
  defaultAllowComments: boolean
  isAuthor: boolean
  userSignedIn: boolean
  request: Request
  links: Links
}): JSX.Element {
  const [allowComments, setAllowComments] = useState(defaultAllowComments)

  const handleCommentsEnabled = useCallback(() => {
    setAllowComments(true)
  }, [])

  const handleCommentsDisabled = useCallback(() => {
    setAllowComments(false)
  }, [])

  return (
    <section className="comments mt-40">
      {userSignedIn ? (
        <React.Fragment>
          <Header
            links={links}
            isAuthor={isAuthor}
            allowComments={allowComments}
            onCommentsEnabled={handleCommentsEnabled}
            onCommentsDisabled={handleCommentsDisabled}
          />
          {allowComments ? (
            <React.Fragment>
              <NewCommentForm
                cacheKey={[request.endpoint]}
                endpoint={links.create}
              />
              <Reminder />
            </React.Fragment>
          ) : null}
        </React.Fragment>
      ) : null}
      {allowComments ? (
        <ListContainer cacheKey={[request.endpoint]} request={request} />
      ) : (
        <ListDisabled isAuthor={isAuthor} />
      )}
    </section>
  )
}
