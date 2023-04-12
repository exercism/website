import React from 'react'
import { GraphicalIcon } from '../common'

const STATUS_DATA = {
  eligible: {
    text: "You're currently eligible for Insiders. Thank you for being part of Exercism. We're excited to take you with us on the next step in our journey.",
    css: '--already-insider',
  },

  ineligible: {
    text: 'Insiders is available to regular contributors, mentors, or donors. Set up a recurring donation to get access.',
    css: '--ineligible',
  },

  lifetime_eligible: {
    text: "We've given you lifetime access to Insiders. Thank you for being part of Exercism. We're excited to take you with us on the next step in our journey.",
    css: '--already-insider',
  },
  unset: {
    text: "We're currently calculating your Insiders status. This box will update once we've finished.",
    css: '--unset',
  },
}

const BUTTON_TEXT = ['Set up a Recurring Donation', 'Get access to Insiders']

export type InsidersStatusData = {
  status: 'eligible' | 'lifetime_eligible' | 'unset' | 'ineligible'
}
export default function Status({ status }: InsidersStatusData): JSX.Element {
  return (
    <div className="min-h-[160px]">
      <div className={`c-insiders-prompt mb-36 ${STATUS_DATA[status].css}`}>
        {STATUS_DATA[status].text}
      </div>

      <a className="get-insiders-link ">
        {BUTTON_TEXT[+(status !== 'unset' && status !== 'ineligible')]}
        <GraphicalIcon icon="arrow-right" />
      </a>
    </div>
  )
}
