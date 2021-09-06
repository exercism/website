import React, { useState, useCallback } from 'react'
import { User } from '../types'
import { Photo } from './avatar-selector/Photo'
import { CroppingModal } from './avatar-selector/CroppingModal'
import { useImageCrop } from './avatar-selector/use-image-crop'

type Links = {
  update: string
}

export const AvatarSelector = ({
  defaultUser,
  links,
}: {
  defaultUser: User
  links: Links
}): JSX.Element => {
  const [user, setUser] = useState(defaultUser)
  const { handleAttach, ...modalProps } = useImageCrop()

  const handleUpload = useCallback((user: User) => {
    setUser(user)
  }, [])

  return (
    <React.Fragment>
      <Photo user={user} onAttach={handleAttach} />
      <CroppingModal
        links={{ upload: links.update }}
        onUpload={handleUpload}
        {...modalProps}
      />
    </React.Fragment>
  )
}
