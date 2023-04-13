import React, { useEffect, useState } from 'react'
import { GraphicalIcon } from '../common'
import { ExercismTippy } from '../misc/ExercismTippy'
import { useMutation } from 'react-query'
import { sendRequest } from '@/utils'
import { typecheck } from '@/utils/typecheck'

const STATUS_DATA = {
  eligible: {
    text: "You're currently eligible for Insiders. Thank you for being part of Exercism. We're excited continue with you on our journey!",
    css: '--already-insider',
  },

  ineligible: {
    text: 'Insiders is available to contributors, mentors, and regular donors. Set up a recurring donation to get access when we launch.',
    css: '--ineligible',
  },

  eligible_lifetime: {
    text: "We've given you lifetime access to Insiders. Thank you for being part of Exercism. We're excited continue with you on our journey!",
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
}

type Response = {
  handle: string
  insidersStatus: InsiderStatus
}

export default function Status(data: InsidersStatusData): JSX.Element {
  const { status, donate_link, insiders_status_request } = data
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

  useEffect(() => {
    if (insidersStatus === 'unset') {
      mutation()
    }
  }, [insidersStatus, mutation])

  const eligible =
    insidersStatus === 'eligible' || insidersStatus === 'eligible_lifetime'

  return (
    <>
      <div
        className={`c-insiders-prompt mb-36 ${STATUS_DATA[insidersStatus].css}`}
      >
        {STATUS_DATA[insidersStatus].text}
      </div>

      {eligible && (
        <ExercismTippy content={<ComingSoon />}>
          <div>
            <button className="flex get-insiders-link grow" disabled>
              <span>{BUTTON_TEXT[+eligible]}</span>
              <GraphicalIcon icon="arrow-right" />
            </button>
          </div>
        </ExercismTippy>
      )}

      {insidersStatus === 'ineligible' && (
        <a href={donate_link} className="flex get-insiders-link grow">
          <span>{BUTTON_TEXT[+eligible]}</span>
          <GraphicalIcon icon="arrow-right" />
        </a>
      )}
    </>
  )
}

function ComingSoon(): JSX.Element {
  return (
    <div className="bg-[#191525] text-aliceBlue text-h6 flex gap-8 py-12 px-12 rounded-8">
      Check back later in the month to get access{' '}
      <GraphicalIcon icon="insiders" height={24} width={24} />
    </div>
  )
}
