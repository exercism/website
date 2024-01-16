import React from 'react'
import { GraphicalIcon } from '@/components/common'

export const ChatGptUpsellContent = (): JSX.Element => {
  return (
    <div className="  px-24 pt-16 pb-24 text-center">
      <div className="border-gradient-lightPurple border-2 rounded-8 px-24 py-16 flex flex-col items-center">
        <GraphicalIcon icon="insiders" className="w-[48px] h-[48px] mb-16" />
        <h2 className="text-h3 mb-2">Exercism Insiders</h2>
        <p className="text-h5 mb-16 max-w-[520px]">
          Donate to Exercism and get behind the scenes access and bonus
          features.
        </p>
        <div className="text-p-base max-w-[520px] mb-16">
          Need help getting unstuck? Unlock our{' '}
          <strong>ChatGPT Integration</strong> and extra mentoring slots, as
          well as Dark Mode, exclusive badges and more, when you donate to
          Exercism.
        </div>

        <a href="/insiders" className="btn-m btn-primary">
          Learn More
        </a>
      </div>
    </div>
  )
}
