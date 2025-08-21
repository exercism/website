import React, { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils/redirect-to'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { User } from '@/components/types'
import { default as AvatarSelector } from './AvatarSelector'
import { useAppTranslation } from '@/i18n/useAppTranslation'

// i18n-key-prefix: newProfileForm
// i18n-namespace: components/profile

type Links = {
  create: string
  update: string
  delete: string
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

export default function NewProfileForm({
  user,
  defaultFields,
  links,
}: {
  user: User
  defaultFields: Fields
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation('components/profile')
  const [fields, setFields] = useState<Fields>(defaultFields)
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResponse>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: links.create,
        method: 'POST',
        body: JSON.stringify({ user: fields }),
      })

      return fetch
    },
    onSuccess: (response) => {
      redirectTo(response.links.profile)
    },
  })

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
            <label htmlFor="name">{t('newProfileForm.fullName')}</label>
            <input
              id="name"
              type="text"
              placeholder={t('newProfileForm.howDoYouWantToBeKnown')}
              required
              onChange={(e) => setFields({ ...fields, name: e.target.value })}
              value={fields.name}
            />
          </div>
          <div className="field">
            <label htmlFor="location">
              {t('newProfileForm.locationOptional')}
            </label>
            <input
              id="location"
              type="text"
              placeholder={t('newProfileForm.whereDoYouCurrentlyLive')}
              onChange={(e) =>
                setFields({ ...fields, location: e.target.value })
              }
              value={fields.location}
            />
            <div className="note">
              {t('newProfileForm.exercismIsMadeUpOfPeople')}
            </div>
          </div>
          <div className="field">
            <label htmlFor="bio">{t('newProfileForm.bioOptional')}</label>
            <textarea
              id="bio"
              placeholder={t('newProfileForm.tellEveryoneABitMore')}
              onChange={(e) => setFields({ ...fields, bio: e.target.value })}
              value={fields.bio}
              maxLength={160}
            />
            <div className="character-count">
              {t('newProfileForm.characters', { length: fields.bio.length })}
            </div>
          </div>
          <FormButton className="btn-primary btn-m" status={status}>
            {t('newProfileForm.createProfile')}
          </FormButton>
          <ErrorBoundary resetKeys={[status]}>
            <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
          </ErrorBoundary>
        </form>
        <AvatarSelector defaultUser={user} links={links} />
      </section>
    </React.Fragment>
  )
}
