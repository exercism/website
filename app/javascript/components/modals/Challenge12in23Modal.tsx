import React, { useCallback, useState } from 'react'
import { Modal, ModalProps } from './Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { FormButton, GraphicalIcon } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export const Challenge12in23Modal = ({
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
      className="m-community-launch"
    >
      <div className="lhs">
        <header>
          <h1>The #12in23 Challenge</h1>

          <p className="">
            Expand your horizons in 2023 by trying out 12 different programming
            languages in Exercism's #12in23 Challenge.
          </p>
        </header>

        <h2>What do I have to do?</h2>
        <p className="mb-12">
          It's simple - complete 5 exercises (not including "Hello World!") in
          12 languages throughout the year. We'll give you a nice progress page
          that shows you how you're getting on, and if you complete the
          challenge we'll give you access to exclusive badges and SWAG.
        </p>

        <p className="mb-12">
          Each month we'll focus on a different paradigm (e.g. functional, OOP,
          low-level, old-school, new, esoteric), and highlight interesting
          solutions and ideas! Join in by using the #12in23 hashtag on social
          media and streaming services, and chat using the tag on our forums.
        </p>

        <p className="mb-12">
          Get started by clicking the card on the right of your dashboard.
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
        <h2 className="text-h4 mb-12">Watch Jeremy's introduction...</h2>
        <div
          className="video relative rounded-8 overflow-hidden !mb-24"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src="https://www.youtube-nocookie.com/embed/Svzev-9shKs"
            title="Introducing the 'Community' tab"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <h2 className="text-h4 mb-12">Which languages should I choose?</h2>
        <p className="text-p-base">
          Try and expand your horizons! Go old-school with COBOL, cutting edge
          with Unison and esoteric with Prolog. Explore low-level code with
          Assembly, expressions with a Lisp and functional with Haskell! There's
          over 60 languages to choose from!
        </p>
      </div>
    </Modal>
  )
}
