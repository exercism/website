import React from 'react'
import { GraphicalIcon, Icon } from '../../common'

export function BecomeRocketFuel(): JSX.Element {
  return (
    <div className="absolute w-[76%] left-[12%] bottom-[-400px] bg-white flex flex-col text-center justify-center rounded-[32px] py-24 px-48 shadow-lg">
      <span className="text-48 mb-8">🚀</span>
      <h2 className="text-h1 mb-12">Become rocket fuel for our mission</h2>
      <p className="text-p-2xlarge mb-36 text-center">
        We’ve built everything for under $500,000. Imagine what we could do with
        serious funding! Could you be the one to make it happen?
      </p>
      <div className="flex flex-col border border-2 border-gradient rounded-16 px-24 py-40">
        <div className="flex flex-row mx-auto mb-24">
          <GraphicalIcon
            className="mr-24"
            width={64}
            height={64}
            icon="avatar-placeholder"
          />
          <div className="flex flex-col text-left">
            <div className="text-h4 mb-4">
              Interested in supporting Exercism as an organisation?
            </div>
            <div className="text-[19px] leading-regular text-textColor5">
              Get in touch with{' '}
              <span className="text-primaryBtnBorder">Lorretta Murray</span>,
              the fundraiser of Exercism.
            </div>
          </div>
        </div>

        <a
          className="py-12 px-18 border-1 border-primaryBtnBorder shadow-xsZ1v3 bg-purple text-white text-16 font-semibold rounded-8 "
          href="mailto:loretta@exercism.org"
        >
          <div className="flex flex-row justify-center">
            <Icon alt="envelope" icon="envelope" className="mr-16" />
            loretta@exercism
          </div>
        </a>
      </div>
    </div>
  )
}
