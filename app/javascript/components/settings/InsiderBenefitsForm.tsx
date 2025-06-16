import React, { useState, useCallback } from 'react'
import { Icon, GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { FormMessage } from './FormMessage'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'

type Links = {
  update: string
  insidersPath: string
}

export type UserPreferences = {
  hideWebsiteAdverts: boolean
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export default function InsiderBenefitsForm({
  defaultPreferences,
  insidersStatus,
  links,
}: {
  defaultPreferences: UserPreferences
  insidersStatus: string
  links: Links
}): JSX.Element {
  const [hideAdverts, setHideAdverts] = useState(
    defaultPreferences.hideWebsiteAdverts
  )

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: links.update,
        method: 'PATCH',
        body: JSON.stringify({
          user_preferences: { hide_website_adverts: hideAdverts },
        }),
      })

      return fetch
    },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const isInsider =
    insidersStatus == 'active' || insidersStatus == 'active_lifetime'

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2 className="!mb-8">Insider Benefits</h2>
      <InfoMessage
        isInsider={isInsider}
        insidersStatus={insidersStatus}
        insidersPath={links.insidersPath}
      />
      <label className="c-checkbox-wrapper">
        <input
          type="checkbox"
          disabled={!isInsider}
          checked={hideAdverts}
          onChange={(e) => setHideAdverts(e.target.checked)}
        />
        <div className="row">
          <div className="c-checkbox">
            <GraphicalIcon icon="checkmark" />
          </div>
          Hide website adverts
        </div>
      </label>
      <div className="form-footer">
        <FormButton
          disabled={!isInsider}
          status={status}
          className="btn-primary btn-m"
        >
          Change preferences
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
      Your preferences have been updated
    </div>
  )
}

export function InfoMessage({
  insidersStatus,
  insidersPath,
  isInsider,
}: {
  insidersStatus: string
  insidersPath: string
  isInsider: boolean
}): JSX.Element {
  if (isInsider) {
    return (
      <p className="text-p-base mb-16">
        Thanks for being an Exercism Insider! Here are some extra settings
        exclusively for you.
      </p>
    )
  }

  switch (insidersStatus) {
    case 'eligible':
    case 'eligible_lifetime':
      return (
        <p className="text-p-base mb-16">
          You&apos;re eligible to join Insiders.{' '}
          <a href={insidersPath}>Get started here.</a>
        </p>
      )
    default:
      return (
        <>
          <p className="text-p-base mb-12">
            These are exclusive options for Exercism Insiders.&nbsp;
          </p>
          <p className="text-p-base mb-12">
            <strong>
              <a className="text-prominentLinkColor" href={insidersPath}>
                Donate to Exercism
              </a>
            </strong>{' '}
            to become an Insider to access benefits such as Dark Mode, ChatGPT
            integration, an advert-free experience, and more.
          </p>
        </>
      )
  }
}
