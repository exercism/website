import React, { useCallback, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { Modal, ModalProps } from './Modal'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export default function WelcomeModal({
  endpoint,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
}): JSX.Element {
  const [open, setOpen] = useState(true)
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: () => {
        setOpen(false)
      },
    }
  )

  const handleClick = useCallback(() => {
    mutation()
  }, [mutation])

  return (
    <Modal
      cover={true}
      open={open}
      {...props}
      onClose={() => null}
      className="m-welcome"
    >
      <div className="lhs">
        <header>
          <h1>Welcome to Exercism! 💙</h1>

          <p className="">
            Exercism is the place to deepen your programming skills and explore
            over 65 programming languages. It&apos;s 100% free.
          </p>
        </header>

        <h2>Thanks for joining!</h2>
        <p className="mb-12">
          Exercism has been made by thousands of people who want to create a
          fun, powerful educational platform that makes it easy to learn and
          deepen your programming skils. We&apos;re really glad you&apos;ve
          joined us for the ride! Check our forums, Youtube and Twitch to
          explore everything Exercism has to offer 🎉
        </p>

        <p className="mb-12">
          To get started, watch the welcome video on the right then head to the
          Tracks page and choose the language you want to explore first. Solve
          the classic &quot;Hello World&quot; exercise to familiarize yourself
          with the platform, then start solving exercises for real.
        </p>

        <FormButton
          status={status}
          className="btn-primary btn-l"
          type="button"
          onClick={handleClick}
        >
          Got it! Close this modal.
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </div>
      <div className="rhs">
        <h2 className="text-h4 mb-12">Start with our welcome video 👇🏽</h2>
        <div
          className="video relative rounded-8 overflow-hidden !mb-24"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src="https://www.youtube-nocookie.com/embed/8rmbTWAncb8"
            title="Introducing the 'Community' tab"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <h2 className="text-h4 mb-4">Where can I join #48in24?</h2>
        <p className="text-p-base mb-8">
          Discovered Exercism because of #48in24 or one of our featured months?
          Good stuff! Once you&apos;ve watched the video above, close this modal
          and you&apos;ll see a big graphic on the right-hand side advertising
          #48in24. Click on that and follow the instructions to get started!
        </p>
      </div>
    </Modal>
  )
}
