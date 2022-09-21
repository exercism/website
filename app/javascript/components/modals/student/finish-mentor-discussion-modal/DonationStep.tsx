import React from 'react'
import { GraphicalIcon } from '../../../common'
import FormWithModal from '../../../donations/FormWithModal'
export function DonationStep({
  mentorHandle,
}: {
  mentorHandle: string
}): JSX.Element {
  return (
    <div className="flex flex-row !w-full">
      <div className="mr-64">
        <h1 className="text-h1 mb-24">
          Thank you for leaving a testimonial for {mentorHandle}! ✨
        </h1>
        <h3 className="text-h2 mb-12">
          One more ask... We need your help to keep Exercism substainable.
        </h3>
        <p className="text-p-large leading-170 mb-24">
          <strong className="font-medium">
            We’re just scratching the surface of what’s possible with Exercism.
          </strong>{' '}
          But we need your help to keep the lights on and enable us to grow and
          expand what we’re doing.{' '}
          {/* probably remove text-p-large because it doesn't do much heavy lifting, and must force semibold because of that */}
          <strong className="!font-semibold">
            Only 1% of people give to Exercism - please be one of them!
          </strong>
        </p>

        <div className="border-2 border-gradient bg-lightPurple mb-32 py-12 px-24 rounded-8">
          <p className="text-gradient font-semibold leading-160 text-17">
            Please help fund Exercism to make it financially sustainable and
            empower us with the creative freedom to build something even more
            amazing than what’s here today!
          </p>
        </div>

        <hr className="border-2 border-crayola mb-32" />

        <h3 className="text-h3 mb-12">Want to help?</h3>
        <p className="text-textColor1 text-18 font-medium leading-170 mb-24">
          Please use the form on the right-hand side to make a one-off or
          recurring donation. Every little helps. Thank you!
        </p>

        <h3 className="text-h3 mb-12">Not for now?</h3>

        <button className="btn-casual py-16 px-24 mb-16">
          Continue to exercise...
        </button>

        <div className="text-15 text-btnBorder leading-160 font-normal">
          Don’t worry, we won’t show you this again for a while.
        </div>
      </div>
      <div className="flex flex-col items-end">
        <GraphicalIcon
          className="mb-40"
          icon="wizard-hat"
          width={111}
          height={87}
          category="graphics"
        />
        {/* load this lazily */}
        <FormWithModal
          links={{ donate: 'asdf', settings: 'asdf' }}
          request={'asdfad'}
          userSignedIn
        />
      </div>
    </div>
  )
}
