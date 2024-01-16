import React from 'react'
import { User } from '../types'
import { AvatarSelector } from '../profile'

type Links = {
  update: string
  delete: string
}

export default function PhotoForm({
  defaultUser,
  links,
}: {
  defaultUser: User
  links: Links
}): JSX.Element {
  return (
    <div className="c-settings-photo-form">
      <h2>Change your photo</h2>
      <hr className="c-divider --small" />
      <AvatarSelector defaultUser={defaultUser} links={links} />
    </div>
  )
}
