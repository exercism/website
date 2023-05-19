import React, { useEffect, useState } from 'react'
import { GraphicalIcon } from '../common'
import { useMutation } from 'react-query'
import { sendRequest } from '@/utils'
import { typecheck } from '@/utils/typecheck'
import { redirectTo } from '@/utils/redirect-to'

const STATUS_DATA = {
  eligible: {
    text: "You're currently eligible for Insiders. Thank you for being part of Exercism. We're excited to continue with you on our journey!",
    css: '--already-insider',
  },

  ineligible: {
    text: 'Insiders is available to contributors, mentors, and regular donors. Earn rep or set up up a recurring donation to get access.',
    css: '--ineligible',
  },

  eligible_lifetime: {
    text: "We've given you lifetime access to Insiders. Thank you for being part of Exercism. We're excited to continue with you on our journey!",
    css: '--already-insider',
  },

  unset: {
    text: "We're currently calculating your Insiders status. This box will update once we've finished.",
    css: '--unset',
  },
}

const BUTTON_TEXT = ['Set up a Recurring Donation', 'Get access to Insiders']

type InsiderStatus = 'eligible' | 'eligible_lifetime' | 'unset' | 'ineligible'
export type InsidersStatusData = {
  status: InsiderStatus
  donate_link: string
  insiders_status_request: string
  activate_insider_link: string
}

type Response = {
  handle: string
  insidersStatus: InsiderStatus
}

export default function Status(data: InsidersStatusData): JSX.Element {
  const {
    status,
    donate_link,
    insiders_status_request,
    activate_insider_link,
  } = data
  const [insidersStatus, setInsidersStatus] = useState(status)

  const [mutation] = useMutation<Response>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: insiders_status_request,
        method: 'GET',
        body: null,
      })

      return fetch.then((json) => typecheck<Response>(json, 'user'))
    },
    {
      onSuccess: (elem) => setInsidersStatus(elem.insidersStatus),
    }
  )

  const [activateInsider] = useMutation(
    async () => {
      const { fetch } = sendRequest({
        endpoint: activate_insider_link,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: (res) => redirectTo(res.links.redirectUrl),
    }
  )

  useEffect(() => {
    if (insidersStatus === 'unset') {
      mutation()
    }
  }, [insidersStatus, mutation])

  const eligible =
    insidersStatus === 'eligible' || insidersStatus === 'eligible_lifetime'

  return (
    <div className="flex flex-col items-start">
      <div
        className={`c-insiders-prompt mb-36 ${STATUS_DATA[insidersStatus].css}`}
      >
        {STATUS_DATA[insidersStatus].text}
      </div>

      {eligible && (
        <button
          className="flex get-insiders-link grow"
          onClick={() => activateInsider()}
        >
          <span>{BUTTON_TEXT[+eligible]}</span>
          <GraphicalIcon icon="arrow-right" />
        </button>
      )}

      {insidersStatus === 'ineligible' && (
        <a href={donate_link} className="flex get-insiders-link grow">
          <span>{BUTTON_TEXT[+eligible]}</span>
          <GraphicalIcon icon="arrow-right" />
        </a>
      )}
    </div>
  )
}
