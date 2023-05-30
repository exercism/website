import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../Editor'

export const ChatGptUpsellPanel = (): JSX.Element => {
  return (
    <Tab.Panel id="chatgpt" context={TabsContext}>
      <>
        <div className="  px-24 pt-16 pb-24 text-center">
          <div className="border-gradient-lightPurple border-2 rounded-8 px-24 py-16 flex flex-col items-center">
            <img
              role="presentation"
              alt=""
              className="c-icon w-[48px] h-[48px] mb-16"
              src="/assets/icons/premium-94f3bd958eeeba6f9c5047976c5ebd6f6d2b0109.svg"
            />
            <h2 className="text-h3 mb-2">Exercism Premium</h2>
            <p className="text-h5 mb-16">
              Supercharge your Exercism Experience!
            </p>
            <div className="text-p-base max-w-[520px] mb-16">
              Need help getting unstuck? Unlock our{' '}
              <strong>ChatGPT Integration</strong> and extra mentoring slots, as
              well as Dark Mode, exclusive badges and more, with Exercism
              Premium. Only $9.99/month
            </div>

            <a href="/premium" className="btn-m btn-primary">
              Learn More
            </a>
          </div>
        </div>
      </>
    </Tab.Panel>
  )
}
