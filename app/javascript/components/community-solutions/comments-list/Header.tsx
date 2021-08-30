import React from 'react'
import { Options } from './Options'

type Links = {
  changeIteration: string
  unpublish: string
  enable: string
  disable: string
}

export const Header = ({
  links,
  isAuthor,
  allowComments,
  onCommentsEnabled,
  onCommentsDisabled,
}: {
  links: Links
  isAuthor: boolean
  allowComments: boolean
  onCommentsEnabled: () => void
  onCommentsDisabled: () => void
}): JSX.Element => {
  return (
    <header className="flex lg:items-center mb-12">
      <h2 className="text-h4">Write a comment</h2>
      {isAuthor ? (
        <Options
          allowComments={allowComments}
          links={links}
          onCommentsEnabled={onCommentsEnabled}
          onCommentsDisabled={onCommentsDisabled}
        />
      ) : null}
    </header>
  )
}
