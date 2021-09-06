import React from 'react'
import { CroppingModal } from '../../profile/avatar-selector/CroppingModal'
import { useImageCrop } from '../../profile/avatar-selector/use-image-crop'

type Links = {
  upload: string
}

export const ChangePhotoButton = ({
  onUpload,
  links,
}: {
  onUpload: (avatarUrl: string) => void
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
