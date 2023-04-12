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
    text: 'Insiders is available to regular contributors, mentors, or donors. Set up a recurring donation to get access.',
    css: '--ineligible',
  },

  lifetime_eligible: {
    text: "We've given you lifetime access to Insiders. Thank you for being part of Exercism. We're excited continue with you on our journey!",
    css: '--already-insider',
  },
  unset: {
    text: "We're currently calculating your Insiders status. This box will update once we've finished.",
    css: '--unset',
  },
}

const BUTTON_TEXT = ['Set up a Recurring Donation', 'Get access to Insiders']

type InsiderStatus = 'eligible' | 'lifetime_eligible' | 'unset' | 'ineligible'
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
    () => {
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

  const eligible = status !== 'ineligible'

  return (
    <>
      <div
        className={`c-insiders-prompt mb-36 ${STATUS_DATA[insidersStatus].css}`}
      >
        {STATUS_DATA[insidersStatus].text}
      </div>

      {insidersStatus !== 'unset' && (
        <ExercismTippy content={<ComingSoon />}>
          <a
            className="flex"
            href={insidersStatus === 'ineligible' ? donate_link : ''}
          >
            <button className="get-insiders-link grow" disabled={eligible}>
              <span>{BUTTON_TEXT[+eligible]}</span>
              <GraphicalIcon icon="arrow-right" />
            </button>
          </a>
        </ExercismTippy>
      )}
    </>
  )
}

function ComingSoon(): JSX.Element {
  return (
    <div className="bg-[#191525] text-aliceBlue text-h6 flex gap-8 py-12 px-24 rounded-16">
      Check back later in the month to get access{' '}
      <GraphicalIcon icon="purple-pixel-heart" height={24} width={24} />
    </div>
  )
}
