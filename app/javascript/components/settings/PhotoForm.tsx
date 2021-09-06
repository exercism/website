import React, { useState, useCallback } from 'react'
import { Avatar } from '../common'
import { User } from '../types'
import { ChangePhotoButton } from './photo-form/ChangePhotoButton'

type Links = {
  update: string
}

export const PhotoForm = ({
  defaultUser,
  links,
}: {
  defaultUser: User
  links: Links
}): JSX.Element => {
  const [user, setUser] = useState(defaultUser)

  const handleUpload = useCallback(
    (avatarUrl: string) => {
      setUser({ ...user, avatarUrl })
    },
    [user]
  )

  return (
    <div className="c-settings-photo-form">
      <h2>Change your photo</h2>
      <hr className="c-divider --small" />
      <Avatar handle={user.handle} src={user.avatarUrl} />
      <ChangePhotoButton
        links={{ upload: links.update }}
        onUpload={handleUpload}
      />
    </div>
  )
}
