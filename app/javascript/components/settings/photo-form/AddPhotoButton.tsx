import React from 'react'
import { CroppingModal } from '../../profile/avatar-selector/CroppingModal'
import { useImageCrop } from '../../profile/avatar-selector/use-image-crop'
import { User } from '../../types'

type Links = {
  upload: string
}

export const AddPhotoButton = ({
  onUpload,
  links,
}: {
  onUpload: (user: User) => void
  links: Links
}): JSX.Element => {
  const { handleAttach, ...modalProps } = useImageCrop()

  return (
    <React.Fragment>
      <input type="file" id="avatar" onChange={handleAttach} />
      <CroppingModal onUpload={onUpload} links={links} {...modalProps} />
    </React.Fragment>
  )
}
