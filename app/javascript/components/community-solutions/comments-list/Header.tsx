import React from 'react'
import { PublishSettings } from '../../student/published-solution/PublishSettings'
import { Iteration } from '../../types'
import { GraphicalIcon } from '../../common'

type Links = {
  changeIteration: string
  unpublish: string
}

export const Header = ({
  iterations,
  publishedIterationIdx,
  links,
}: {
  iterations: readonly Iteration[]
  publishedIterationIdx: number | null
  links: Links
}): JSX.Element => {
  return (
    <header className="flex items-center mb-12">
      <h2 className="text-h4">Write a comment</h2>
      {links.changeIteration && links.unpublish ? (
        <PublishSettings
          links={{
            changeIteration: links.changeIteration,
            unpublish: links.unpublish,
          }}
          publishedIterationIdx={publishedIterationIdx}
          iterations={iterations}
          redirectType="public"
          className="btn-s text-14 text-textColor6 ml-auto"
        >
          <GraphicalIcon icon="settings" />
          <span>Options</span>
        </PublishSettings>
      ) : null}
    </header>
  )
}
