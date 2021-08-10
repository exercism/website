import React from 'react'
import { Iteration } from '../../types'
import { Options } from './Options'

type Links = {
  changeIteration: string
  unpublish: string
  enable: string
  disable: string
}

export const Header = ({
  iterations,
  publishedIterationIdx,
  links,
  isAuthor,
  allowComments,
  onCommentsEnabled,
  onCommentsDisabled,
}: {
  iterations: readonly Iteration[]
  publishedIterationIdx: number | null
  links: Links
  isAuthor: boolean
  allowComments: boolean
  onCommentsEnabled: () => void
  onCommentsDisabled: () => void
}): JSX.Element => {
  return (
    <header className="flex items-center mb-12">
      <h2 className="text-h4">Write a comment</h2>
      {isAuthor ? (
        <Options
          allowComments={allowComments}
          links={links}
          publishedIterationIdx={publishedIterationIdx}
          iterations={iterations}
          redirectType="public"
          onCommentsEnabled={onCommentsEnabled}
          onCommentsDisabled={onCommentsDisabled}
        />
      ) : null}
    </header>
  )
}
