import React, { useCallback, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from './Modal'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export default function WelcomeToInsidersModal({
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
    async () => {
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
      theme="dark"
      className="m-welcome"
    >
      <div className="lhs">
        <header>
          <h1>Welcome to Insiders! 💙</h1>

          <p className="">
            You now have access to Dark Mode, ChatGPT Integration, extra
            mentoring slots along with behind the scenes videos, new badges, and
            more!
          </p>
        </header>

        <h2>Thanks for being part of our story!</h2>
        <p className="mb-12">
          Exercism relies on people like you giving up your time and money to
          help others. Without you we wouldn&apos;t have helped the multitude of
          people that we have. Our journey is still just beginning and
          we&apos;re really glad to have you along with us. Thank you so much
          for making Exercism possible 💙
        </p>

        <p className="mb-12">
          We hope Insiders is a fun experience. We recommend watching the video
          on the right to get an overview of how your account has now changed,
          and also checking out the Insiders page behind this modal to see all
          the features you&apos;ve unlocked.
        </p>

        <FormButton
          status={status}
          className="btn-primary btn-l"
          type="button"
          onClick={handleClick}
        >
          Great. Let&apos;s go!
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
            src="https://www.youtube-nocookie.com/embed/zomfphsDQrs"
            title="Welcome to Exercism Insiders!"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <h2 className="text-h4 mb-4">What should I do next?</h2>
        <p className="text-p-base mb-8">
          Explore Dark Mode (we&apos;ve enabled it by default). Check out your
          new badge(s). Try ChatGPT in the online editor. Use one of your new
          mentoring slots. Come and say hello on the #insiders channel on
          Discord. Or watch some of the behind the scenes videos 🎉
        </p>
      </div>
    </Modal>
  )
}
