import React, { lazy, Suspense, useCallback, useState } from 'react'
import currency from 'currency.js'
import { PaymentIntentType } from '@/components/donations/stripe-form/useStripeForm'
import { Request } from '@/hooks/request-query'
import { StripeFormLinks } from '@/components/donations/Form'
import { Modal } from '.'
import SuccessModal from '../donations/SuccessModal'
const Form = lazy(() => import('@/components/donations/Form'))

function PreviousDonorContent() {
  return (
    <>
      <p className="text-p-large mb-12">
        You're one of the few people who have donated to Exercism. Thank you so
        much for supporting us 💙
      </p>
      <p className="text-p-large mb-12">
        I hate to ask you again (😔), but we really need your support. Exercism
        isn't covering its costs and we really need your help. If you're
        enjoying Exercism and can afford it,{' '}
        <strong className="font-medium">
          please consider donating a few more dollars{' '}
        </strong>
        to support us.
      </p>

      <p className="text-p-large">
        If possible, a monthly donation would be extra helpful! It takes 30
        seconds to setup using the form on the right 👉
      </p>
    </>
  )
}

function NonDonorContent() {
  return (
    <>
      <p className="text-p-large mb-12">
        Exercism relies on donations. But right now we don't have enough 😔
      </p>
      <p className="text-p-large mb-12">
        Most people who use Exercism can't afford to donate. But if you can, and
        you're finding Exercism useful,{' '}
        <strong className="font-medium">
          please consider donating a few dollars{' '}
        </strong>
        so that we can keep it free for those who can't afford it.
      </p>
      <p className="text-p-large">
        If only 1% of our users support us regularly, we'll be able to cover our
        costs. It takes 30 seconds to donate, using the form on the right 👉
      </p>
    </>
  )
}

export default function ({
  previousDonor,
  links,
  request,
}: {
  previousDonor: boolean
  links: StripeFormLinks
  request: Request
}): JSX.Element {
  const [isModalOpen, setIsModalOpen] = useState(true)
  const [paymentMade, setPaymentMade] = useState(false)
  const [paymentAmount, setPaymentAmount] = useState<currency | null>(null)

  const handleSuccess = useCallback(
    (_type: PaymentIntentType, amount: currency) => {
      setIsModalOpen(false)
      setPaymentAmount(amount)
      setPaymentMade(true)
    },
    []
  )

  return (
    <>
      <Modal
        style={{ content: { maxWidth: 'fit-content' } }}
        cover
        aria={{ modal: true, describedby: 'a11y-finish-mentor-discussion' }}
        className="m-finish-student-mentor-discussion"
        containerClassName="!p-48"
        ReactModalClassName="bg-unnamed15"
        shouldCloseOnOverlayClick={false}
        shouldCloseOnEsc={false}
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      >
        <div id="a11y-finish-mentor-discussion" className="flex flex-row">
          <div className="mr-64 max-w-[700px]">
            <h3 className="text-h4 mb-4 text-prominentLinkColor">
              Sorry to disturb, but...
            </h3>
            <h1 className="text-h1 mb-12">We need your help!</h1>

            <div className="mb-20 pb-20 border-b-1 border-borderColor7">
              {previousDonor ? <PreviousDonorContent /> : <NonDonorContent />}
            </div>

            <h3 className="text-h4 mb-6">Can't afford it?</h3>
            <p className="text-p-large mb-20">
              If you can&apos;t afford to donate, but would like to help in some
              other way, please share Exercism with your friends and colleagues,
              and shout about us on social media. The more people that use us,
              the more donations we get!
            </p>

            <h3 className="text-h4 mb-6">Want to know more?</h3>
            <p className="text-p-large mb-20">
              I put together a short video that explains why we need donations
              and how we use them 👇
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
          </div>
          <div className="flex flex-col items-end bg-transparent">
            <div className="w-[564px] shadow-lgZ1 rounded-8 mb-20">
              <Suspense fallback={<div className="c-loading-suspense" />}>
                <Form
                  request={request}
                  defaultAmount={{
                    payment: currency(16),
                    subscription: currency(16),
                  }}
                  userSignedIn={true}
                  captchaRequired={false}
                  links={links}
                  onSuccess={handleSuccess}
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
        <div className="flex items-center border-t-1 border-borderColor6 pt-20">
          <button
            onClick={() => setIsModalOpen(false)}
            className="btn-enhanced btn-l !shadow-xsZ1v3 py-16 px-24"
          >
            Continue without donating
          </button>
        </div>
      </Modal>
      <SuccessModal
        open={paymentMade}
        amount={paymentAmount}
        closeLink={links.success}
      />
    </>
  )
}
