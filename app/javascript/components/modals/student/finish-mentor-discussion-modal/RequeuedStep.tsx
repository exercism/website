import React from 'react'

type Links = {
  exercise: string
}

export const RequeuedStep = ({ links }: { links: Links }): JSX.Element => {
  return (
    <div>
      <a href={links.exercise}>Continue</a>
    </div>
  )
}
