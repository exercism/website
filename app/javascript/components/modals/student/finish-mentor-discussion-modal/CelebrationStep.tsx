import React from 'react'

type Links = {
  exercise: string
}

export const CelebrationStep = ({ links }: { links: Links }): JSX.Element => {
  return (
    <div>
      <a href={links.exercise}>Complete</a>
    </div>
  )
}
