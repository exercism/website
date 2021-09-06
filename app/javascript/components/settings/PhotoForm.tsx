import React from 'react'
import { AvatarSelector } from '../profile'
import { User } from '../types'

type Links = {
  update: string
}

export const PhotoForm = ({
  user,
  links,
}: {
  user: User
  links: Links
}): JSX.Element => {
  return (
    <div>
      <h2>Change your photo</h2>
      <hr className="c-divider --small" />
      <AvatarSelector user={user} links={links} />
    </div>
  )
}
