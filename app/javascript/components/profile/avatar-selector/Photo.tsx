import React from 'react'
import { Avatar } from '../../common'
import { DeletePhotoButton } from './photo/DeletePhotoButton'
import { User } from '../../types'

type Links = {
  delete: string
}

export const Photo = ({
  user,
  onAttach,
  onDelete,
  links,
}: {
  user: User
  onAttach: (e: React.ChangeEvent<HTMLInputElement>) => void
  onDelete: (user: User) => void
  links: Links
}): JSX.Element => {
  return (
    <div className="c-avatar-selector">
      <label htmlFor="avatar">
        <Avatar handle={user.handle} src={user.avatarUrl} />
      </label>
      <div className="--details">
        <h2>Your profile picture</h2>
        <div className="faux-button">
          <div className="btn btn-enhanced btn-s">Upload new image</div>
          <input type="file" id="avatar" onChange={onAttach} />
          <div className="hover-bg" />
        </div>
        <div className="cropping">You can crop the image after uploading.</div>
        {user.hasAvatar ? (
          <div className="deleting">
            You can also <DeletePhotoButton links={links} onDelete={onDelete} />
            .
          </div>
        ) : null}
      </div>
    </div>
  )
}
