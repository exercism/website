import React from 'react'
import { Avatar } from '../../common'
import { User } from '../../types'

export const Photo = ({
  user,
  onAttach,
}: {
  user: User
  onAttach: (e: React.ChangeEvent<HTMLInputElement>) => void
}): JSX.Element => {
  return (
    <div className="c-avatar-selector">
      <label htmlFor="avatar">
        <Avatar handle={user.handle} src={user.avatarUrl} />
      </label>
      <h2>Your profile picture</h2>
      <div className="faux-button">
        <div className="btn btn-enhanced btn-s">Upload new image</div>
        <input type="file" id="avatar" onChange={onAttach} />
        <div className="hover-bg" />
      </div>
      <div className="cropping">
        You’ll get to crop the image after uploading
      </div>
    </div>
  )
}
