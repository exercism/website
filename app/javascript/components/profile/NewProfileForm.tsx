import React, { useState, useCallback } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { redirectTo } from '../../utils/redirect-to'
import { FormButton } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'
import { AvatarSelector } from './AvatarSelector'

type Links = {
  create: string
  update: string
}

export type User = {
  handle: string
  avatarUrl: string
}

type APIResponse = {
  links: {
    profile: string
  }
}

type Fields = {
  name: string
  bio: string
  location: string
}

const DEFAULT_ERROR = new Error('Unable to create profile')

export const NewProfileForm = ({
  user,
  defaultFields,
  links,
}: {
  user: User
  defaultFields: Fields
  links: Links
}): JSX.Element => {
  const [fields, setFields] = useState<Fields>(defaultFields)
  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
      const { fetch } = sendRequest({
        endpoint: links.create,
        method: 'POST',
        body: JSON.stringify({ user: fields }),
      })

      return fetch
    },
    {
      onSuccess: (response) => {
        redirectTo(response.links.profile)
      },
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )
  return (
    <React.Fragment>
      <section className="form-section">
        <form onSubmit={handleSubmit} data-turbo="false">
          <div className="field">
            <label htmlFor="name">Full Name</label>
            <input
              id="name"
              type="text"
              placeholder="How do you want to be known?"
              required
              onChange={(e) => setFields({ ...fields, name: e.target.value })}
              value={fields.name}
            />
          </div>
          <div className="field">
            <label htmlFor="location">Loation (optional)</label>
            <input
              id="location"
              type="text"
              placeholder="Where do you currently live?"
              onChange={(e) =>
                setFields({ ...fields, location: e.target.value })
              }
              value={fields.location}
            />
            <div className="note">
              Exercism is made up of people from all over the world 🌎
            </div>
          </div>
          <div className="field">
            <label htmlFor="bio">Bio (optional)</label>
            <textarea
              id="bio"
              placeholder="Tell everyone a bit more about who you are, and what you're in to. e.g. I'm a Rails dev who loves bouldering and coffee"
              onChange={(e) => setFields({ ...fields, bio: e.target.value })}
              value={fields.bio}
              maxLength={160}
            />
            <div className="character-count">
              {fields.bio.length} / 160 characters
            </div>
          </div>
          <FormButton className="btn-primary btn-m" status={status}>
            Create profile
          </FormButton>
          <ErrorBoundary resetKeys={[status]}>
            <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
          </ErrorBoundary>
        </form>
        <AvatarSelector user={user} links={links} />
      </section>
    </React.Fragment>
  )
}
