import React, { useState, useCallback } from 'react'
import { FormButton, GraphicalIcon, Icon } from '../common'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'

type User = {
  name: string
  location: string
  bio: string
}

type Links = {
  update: string
}

const DEFAULT_ERROR = new Error('Unable to save profile')

export const ProfileForm = ({
  defaultUser,
  links,
}: {
  defaultUser: User
  links: Links
}): JSX.Element => {
  const [user, setUser] = useState<User>(defaultUser)

  const { mutation, status, error } = useSettingsMutation<{ user: User }>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user: user },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form onSubmit={handleSubmit}>
      <h2>Profile</h2>
      <div className="details">
        <div className="name field">
          <label htmlFor="user_name" className="label">
            Name
          </label>
          <input
            id="user_name"
            type="text"
            value={user.name || ''}
            onChange={(e) => setUser({ ...user, name: e.target.value })}
            required
          />
        </div>
        <div className="location field">
          <label htmlFor="user_location" className="label">
            Location
          </label>
          <label className="c-faux-input">
            <GraphicalIcon icon="location" />
            <input
              id="user_location"
              type="text"
              value={user.location || ''}
              onChange={(e) => setUser({ ...user, location: e.target.value })}
            />
          </label>
        </div>
      </div>
      <div className="bio field">
        <label htmlFor="user_bio" className="label">
          Bio
        </label>
        <textarea
          id="user_bio"
          value={user.bio || ''}
          onChange={(e) => setUser({ ...user, bio: e.target.value })}
        />
        <div className="instructions">
          Tell the world about you 🌎. Emojis encouraged!
        </div>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Save profile data
        </FormButton>
        <FormMessage
          status={status}
          defaultError={DEFAULT_ERROR}
          error={error}
          SuccessMessage={SuccessMessage}
        />
      </div>
    </form>
  )
}

const SuccessMessage = () => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your profile has been saved
    </div>
  )
}
