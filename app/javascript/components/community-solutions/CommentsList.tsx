import React from 'react'
import { Header } from './comments-list/Header'
import { NewCommentForm } from './comments-list/NewCommentForm'
import { Reminder } from './comments-list/Reminder'
import { ListContainer } from './comments-list/ListContainer'
import { Request } from '../../hooks/request-query'
import { Iteration } from '../types'

export type Links = {
  create: string
  changeIteration: string
  unpublish: string
}

export const CommentsList = ({
  request,
  links,
  iterations,
  publishedIterationIdx,
}: {
  request: Request
  iterations: readonly Iteration[]
  publishedIterationIdx: number | null
  links: Links
}): JSX.Element => {
  const cacheKey = request.endpoint

  return (
    <section className="comments mt-40">
      <Header
        iterations={iterations}
        publishedIterationIdx={publishedIterationIdx}
        links={links}
      />
      <NewCommentForm cacheKey={cacheKey} endpoint={links.create} />
      <Reminder />
      <ListContainer cacheKey={cacheKey} request={request} />
    </section>
  )
}
