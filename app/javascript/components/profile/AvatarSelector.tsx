import React, { useState, useCallback } from 'react'
import { Photo } from './avatar-selector/Photo'
import { CroppingModal } from './avatar-selector/CroppingModal'
import { useImageCrop } from './avatar-selector/use-image-crop'
import { User } from '../types'

type Links = {
  update: string
  delete: string
}

export default function AvatarSelector({
  defaultUser,
  links,
}: {
  defaultUser: User
  links: Links
}): JSX.Element {
  const [user, setUser] = useState(defaultUser)
  const { handleAttach, ...modalProps } = useImageCrop()

  const handleUpdate = useCallback((user: User) => {
    setUser(user)
  }, [])

  return (
    <React.Fragment>
      <Photo
        user={user}
        onAttach={handleAttach}
        onDelete={handleUpdate}
        links={links}
      />
      <CroppingModal links={links} onUpload={handleUpdate} {...modalProps} />
    </React.Fragment>
  )
}
