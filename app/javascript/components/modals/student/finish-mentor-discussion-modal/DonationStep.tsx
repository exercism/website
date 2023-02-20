import React, { lazy, Suspense } from 'react'
import { GraphicalIcon } from '@/components/common'
import { DonationLinks } from '@/components/types'
const DonationsFormWithModal = lazy(
  () => import('@/components/donations/FormWithModal')
)
export function DonationStep({
  mentorHandle,
  donationLinks,
  exerciseLink,
}: {
  mentorHandle: string
  donationLinks: DonationLinks
  exerciseLink: string
}): JSX.Element {
  return (
    <div id="a11y-finish-mentor-discussion" className="flex flex-row">
      <div className="mr-64">
        <h1 className="text-h1 mb-24">
          Thank you for leaving a testimonial for {mentorHandle}! ✨
        </h1>
        <h3 className="text-h2 mb-12">
          One more ask... We need your help to keep Exercism sustainable.
        </h3>
        <p className="text-p-large leading-170 mb-24">
          <strong className="font-medium">
            We&apos;re just scratching the surface of what&apos;s possible with
            Exercism.
          </strong>{' '}
          But we need your help to keep the lights on and enable us to grow and
          expand what we&apos;re doing.{' '}
          <strong className="!font-semibold">
            Only 1% of people give to Exercism - please be one of them!
          </strong>
        </p>

        <div className="border-2 border-gradient bg-lightPurple mb-32 py-12 px-24 rounded-8">
          <p className="text-gradient font-semibold leading-160 text-17">
            Please help fund Exercism to make it financially sustainable and
            empower us with the creative freedom to build something even more
            amazing than what&apos;s here today!
          </p>
        </div>

        <hr className="border-2 border-crayola mb-32" />

        <h3 className="text-h3 mb-12">Want to help?</h3>
        <p className="text-textColor1 text-18 font-medium leading-170 mb-24">
          Please use the form on the right-hand side to make a one-off or
          recurring donation. Every little helps. Thank you!
        </p>

        <h3 className="text-h3 mb-12">Not for now?</h3>

        <div className="flex">
          <a
            href={exerciseLink}
            className="btn-enhanced btn-l !shadow-xsZ1v3 py-16 px-24 mb-16"
          >
            Continue to exercise...
          </a>
        </div>

        <div className="text-15 text-btnBorder leading-160 font-normal">
          Don&apos;t worry, we won&apos;t show you this again for a while.
        </div>
      </div>
      <div className="flex flex-col items-end bg-transparent">
        <GraphicalIcon
          className="mb-40 mr-[53px] !drop-shadow-[0_4px_128px_rgba(79, 114, 205, 0.8)]"
          icon="wizard-hat"
          category="graphics"
        />

        <div className="w-[564px]">
          <Suspense fallback={<div className="c-loading-suspense" />}>
            <DonationsFormWithModal
              request={donationLinks.request}
              links={donationLinks.links}
              userSignedIn={donationLinks.userSignedIn}
              captchaRequired={donationLinks.captchaRequired}
              recaptchaSiteKey={donationLinks.recaptchaSiteKey}
            />
          </Suspense>
        </div>
      </div>
    </div>
  )
}
