import React, { useState, useCallback } from 'react'
import { Avatar } from '../common'
import { User } from '../types'
import { ChangePhotoButton } from './photo-form/ChangePhotoButton'
import { AddPhotoButton } from './photo-form/AddPhotoButton'
import { RemovePhotoButton } from './photo-form/RemovePhotoButton'

type Links = {
  update: string
  destroy: string
}

export const PhotoForm = ({
  defaultUser,
  links,
}: {
  defaultUser: User
  links: Links
}): JSX.Element => {
  const [user, setUser] = useState(defaultUser)

  const handleUpdate = useCallback((user: User) => {
    setUser(user)
  }, [])

  return (
    <div className="c-settings-photo-form">
      <h2>Change your photo</h2>
      <hr className="c-divider --small" />
      <Avatar handle={user.handle} src={user.avatarUrl} />
      {user.isAvatarAttached ? (
        <ChangePhotoButton
          links={{ upload: links.update }}
          onUpload={handleUpdate}
        />
      ) : (
        <AddPhotoButton
          links={{ upload: links.update }}
          onUpload={handleUpdate}
        />
      )}
      {user.isAvatarAttached ? (
        <RemovePhotoButton
          links={{ remove: links.destroy }}
          onDelete={handleUpdate}
        />
      ) : null}
    </div>
  )
}
