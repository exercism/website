import React, { lazy, Suspense } from 'react'
import { MentoringSessionDonation } from '@/components/types'
import currency from 'currency.js'
import { DiscussionActionsLinks } from '@/components/student/mentoring-session/DiscussionActions'
import { PaymentIntentType } from '@/components/donations/stripe-form/useStripeForm'
import { PreviousDonorContent, NonDonorContent } from '../../BegModal'
const Form = lazy(() => import('@/components/donations/Form'))

export function DonationStep({
  donation,
  links,
  onSuccessfulDonation,
}: {
  donation: MentoringSessionDonation
  links: DiscussionActionsLinks
  onSuccessfulDonation: (type: PaymentIntentType, amount: currency) => void
}): JSX.Element {
  return (
    <div id="a11y-finish-mentor-discussion" className="flex flex-row">
      <div className="mr-64 max-w-[700px]">
        <h3 className="text-h4 mb-4 text-prominentLinkColor">
          One more request…
        </h3>
        <h1 className="text-h1 mb-12">Are you finding Exercism helpful?</h1>

        <div className="mb-20 pb-20 border-b-1 border-borderColor7">
          {!donation.previousDonor ? (
            <PreviousDonorContent />
          ) : (
            <NonDonorContent />
          )}
        </div>

        <h3 className="text-h4 mb-6">Can't afford it?</h3>
        <p className="text-p-large mb-20">
          If you can&apos;t afford to donate, but would like to help in some
          other way, please share Exercism with your friends and colleagues, and
          shout about us on social media. The more people that use us, the more
          donations we get!
        </p>

        <h3 className="text-h4 mb-6">Want to know more?</h3>
        <p className="text-p-large mb-20">
          I put together a short video that explains why we need donations and
          how we use them 👇
        </p>

        <div className="c-youtube-container mb-32">
          <iframe
            width="560"
            height="315"
            frameBorder="0"
            src="https://player.vimeo.com/video/855534271?h=97d3a4c8c2&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479&transparent=0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
          <script src="https://player.vimeo.com/api/player.js" />
        </div>

        <div className="flex">
          <a
            href={links.exercise}
            className="btn-enhanced btn-l !shadow-xsZ1v3 py-16 px-24 mb-16"
          >
            Continue without donating
          </a>
        </div>
      </div>
      <div className="flex flex-col items-end bg-transparent">
        <div className="w-[564px] shadow-lgZ1 rounded-8 mb-20">
          <Suspense fallback={<div className="c-loading-suspense" />}>
            <Form
              request={donation.request}
              defaultAmount={{
                payment: currency(16),
                subscription: currency(16),
              }}
              userSignedIn={true}
              captchaRequired={false}
              links={{
                success: links.exerciseMentorDiscussionUrl,
                settings: links.donationsSettings,
              }}
              onSuccess={onSuccessfulDonation}
            />
          </Suspense>
        </div>

        <div className="w-[564px] border-2 border-gradient bg-lightPurple py-12 px-24 rounded-8">
          <p className="text-gradient font-semibold leading-160 text-17">
            Fewer than 1% of who use Exercism choose to donate. If you can
            afford to do so, please be one of them.
          </p>
        </div>
      </div>
    </div>
  )
}
