import React from 'react'
import { ShareButton } from './ShareButton'

type Links = {
  solution: string
}

export const ShareSolutionButton = ({
  title,
  links,
}: {
  title: string
  links: Links
}): JSX.Element => {
  return (
    <ShareButton
      title={title}
      shareTitle="View my solution on Exercism"
      shareLink={links.solution}
    />
  )
}
