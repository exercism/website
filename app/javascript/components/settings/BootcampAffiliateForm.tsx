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

export default function BootcampAffiliateForm({
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
  } = useMutation(async () => {
    const { fetch } = sendRequest({
      endpoint: links.update,
      method: 'PATCH',
      body: JSON.stringify({
        user_preferences: { hide_website_adverts: hideAdverts },
      }),
    })

    return fetch
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
      <h2>Bootcamp Affiliate</h2>
      <InfoMessage
        isInsider={isInsider}
        insidersStatus={insidersStatus}
        insidersPath={links.insidersPath}
      />
      <button className="btn btn-primary">Click to generate code</button>
    </form>
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
        You've not yet generated your affiliate code.
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
        <p className="text-p-base mb-16">
          These are exclusive options for Exercism Insiders.&nbsp;
          <strong>
            <a className="text-prominentLinkColor" href={insidersPath}>
              Donate to Exercism
            </a>
          </strong>{' '}
          and become an Insider to access these benefits with Dark Mode, ChatGPT
          integration and more.
        </p>
      )
  }
}
