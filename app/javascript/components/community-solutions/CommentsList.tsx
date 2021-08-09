import React from 'react'
import { Header } from './comments-list/Header'
import { NewCommentForm } from './comments-list/NewCommentForm'
import { Reminder } from './comments-list/Reminder'
import { ListContainer } from './comments-list/ListContainer'
import { Request } from '../../hooks/request-query'

type Links = {
  create: string
}

export const CommentsList = ({
  request,
  links,
}: {
  request: Request
  links: Links
}): JSX.Element => {
  const cacheKey = request.endpoint

  return (
    <section className="comments mt-40">
      <Header />
      <NewCommentForm cacheKey={cacheKey} endpoint={links.create} />
      <Reminder />
      <ListContainer cacheKey={cacheKey} request={request} />
    </section>
  )
}
