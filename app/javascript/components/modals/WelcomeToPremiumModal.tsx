import React, { useCallback, useState } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '@/utils'
import { Modal, ModalProps } from './Modal'
import { FormButton } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export const WelcomeToPremiumModal = ({
  endpoint,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
}): JSX.Element => {
  const [open, setOpen] = useState(true)
  const [mutation, { status, error }] = useMutation(
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
        handleClose()
      },
    }
  )

  const handleClick = useCallback(() => {
    mutation()
  }, [mutation])

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    setOpen(false)
  }, [status])

  return (
    <Modal
      cover={true}
      open={open}
      {...props}
      onClose={() => null}
      theme="dark"
      className="m-community-launch"
    >
      <div className="lhs">
        <header>
          <h1>Welcome to Premium! 💎</h1>

          <p>
            Thanks for upgrading! We really hope you enjoy the new features and
            functionality you've unlocked.
          </p>
        </header>

        <h2>Thanks for joining!</h2>
        <p className="mb-12">
          We've created Premium as a way of keping the core Exercism product
          free for everyone. By upgrading to Premium, not only have you unlocked
          new features and functionality, you've also helped an open-source,
          not-for-profit organisation that's determined to make access to
          education more equal. So thank you so much for supporting us! 💙
        </p>

        <p className="mb-12">
          To get started with Premium, watch the welcome video on the right then
          close this modal and explore the various features and functionality
          you've unlocked. If you've got ideas for what you'd like to see added
          to Premium, let us know on the forum!
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
            src="https://www.youtube-nocookie.com/embed/V8Ey6HNIY6U"
            title="Welcome to Exercism Premium!"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <h2 className="text-h4 mb-4">What should I do next?</h2>
        <p className="text-p-base mb-8">
          Explore Dark Mode (we've enabled it by default for you). Check out
          your new badge(s). Try ChatGPT in the online editor. Use one of your
          new mentoring slots. And if you're feeling extra generous, post on
          social media and tell all your friends that they should upgrade too!
          🎉
        </p>
      </div>
    </Modal>
  )
}
