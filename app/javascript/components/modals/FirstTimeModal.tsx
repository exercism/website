import React, { useCallback, useState } from 'react'
import { Modal, ModalProps } from './Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { Avatar, FormButton, GraphicalIcon } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'
import { User } from '../types'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export const FirstTimeModal = ({
  endpoint,
  contributors,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
  contributors: readonly User[]
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
      open={open}
      {...props}
      onClose={handleClose}
      className="m-welcome-to-v3"
    >
      <div className="lhs">
        <header>
          <h1>Welcome to Exercism V3! 🎉</h1>
          <p>
            Phew! It’s been long in the making, but we’re finally here.
            <br />
            <strong>Welcome to version 3 of Exercism.</strong>
          </p>
        </header>

        <h2>So, what’s the big deal?</h2>
        <p>
          We’ve updated and improved the whole Exercism experience from the
          ground up. Here are just a few of the excited new things you’ll notice
          as you use Exercism v3:
        </p>

        <div className="improvements">
          <div className="improvement">
            <GraphicalIcon icon="exercise" category="graphics" />
            <div className="info">
              <h3>Learning Mode</h3>
              <p>
                Exercism’s not just about practicing - you can now use it to
                learn too, with our new Concepts and Exercises.
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="editor" category="graphics" />
            <div className="info">
              <h3>Introducing the Exercism editor</h3>
              <p>
                Jump in and try new languages straight away in your browser
                without installing anything locally. And the CLI is still there
                if you like the original way!
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="reputation" category="graphics" />
            <div className="info">
              <h3>Reputation &amp; badges</h3>
              <p>
                The more you contribute to exercism the faster you get mentored.
                Unlock badges for achievements. Show them off on your profile.
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="journey" category="graphics" />
            <div className="info">
              <h3>Your Journey</h3>
              <p>
                Explore everything you’ve done on Exercism. From your learning,
                mentoring and contributions.
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="mentoring" category="graphics" />
            <div className="info">
              <h3>New mentoring</h3>
              <p>
                No more blocking. More automation. Ability to get friends to
                mentor you.
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="ux" category="graphics" />
            <div className="info">
              <h3>New look and feel</h3>
              <p>
                We’ve taken Exercism to the next level with a whole new user
                experience, improving every aspect of the website.
              </p>
            </div>
          </div>
        </div>

        <FormButton
          status={status}
          className="btn-primary btn-l"
          type="button"
          onClick={handleClick}
        >
          I’m ready to explore the new Exercism!
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </div>
      <div className="rhs">
        <div
          className="video"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src="https://player.vimeo.com/video/121725838?title=0&byline=0&portrait=0"
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
            }}
            frameBorder="0"
            allow="autoplay; fullscreen; picture-in-picture"
            allowFullScreen
          />
        </div>
        <script src="https://player.vimeo.com/api/player.js"></script>
        <div className="thank-you">
          <h3>
            The biggest thank you to everyone who helped make v3 a reality 💙
          </h3>
          <p>
            Exercism&apos;s continued evolution would not be possible if not for
            these wonderful people.
          </p>
          <ul className="contributors">
            {contributors.map((c) => {
              return (
                <li key={c.handle}>
                  <Avatar handle={c.handle} src={c.avatarUrl} />
                </li>
              )
            })}
          </ul>
        </div>
      </div>
    </Modal>
  )
}
