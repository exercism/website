import React, { useCallback, useState } from 'react'
import { Modal, ModalProps } from './Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { FormButton, GraphicalIcon } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export const CommunityLaunchModal = ({
  endpoint,
  jonathanImageUrl,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
  jonathanImageUrl: string
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
          <h1>The new &quot;Community&quot; tab</h1>

          <p>
            We think our community is pretty special - thousands of people
            learning, mentoring and supporting each other in a non-toxic
            environment. Well, from today we&apos;re focusing even more on
            making Exercism a great place for you all to spend time.
          </p>
        </header>

        <h2>So, what&apos;s new?</h2>
        <p>
          We&apos;ve added a few new sections to Exercism. Everything is
          accessible via the new Community tab.
        </p>

        <div className="improvements">
          <div className="improvement">
            <GraphicalIcon icon="forum" category="graphics" />
            <div className="info">
              <h3>Exercism&apos;s Forum</h3>
              <p>
                Our new forum is a fun space to chat about programming, help
                guide the future of Exercism, get support if you get stuck, and
                hang out with each other.
              </p>
            </div>
          </div>

          <div className="improvement">
            <GraphicalIcon icon="dig-deeper" category="graphics" />
            <div className="info">
              <h3>Dig Deeper</h3>
              <p>
                We&apos;re pulling the thousands of community walkthroughs into
                one place along with commentary and guidance on exercises. Look
                out for the new Dig Deeper tab on exercises!
              </p>
            </div>
          </div>

          <div className="improvement">
            <GraphicalIcon icon="community-stories" category="graphics" />
            <div className="info">
              <h3>Community Stories</h3>
              <p>
                Sit back, get inspired and enjoy inspiring tales from
                Exercism&apos;s community in our new Community Stories section.
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="swag" category="graphics" />
            <div className="info">
              <h3>Swag</h3>
              <p>
                People have been asking us for swag forever. Well now its here!
                T-shirts, hoodies, bags, jigsaws, even phone cases - show your
                love for Exercism with some high-quality merch.
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
          Sounds good! Let&apos;s go.
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </div>
      <div className="rhs">
        <div
          className="video relative rounded-8 overflow-hidden mb-32"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src="https://www.youtube-nocookie.com/embed/Oib6eB6968Y"
            title="Introducing the 'Community' tab"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <script src="https://player.vimeo.com/api/player.js"></script>
        <div className="thank-you">
          <h3>This wouldn&apos;t be possible without your kind donations 💙</h3>
          <p className="mb-8">
            Thanks to your kind donations, we&apos;ve been able to hire
            Jonathan, our new Community Manager, who can now dedicate the time
            and resource we need to properly nurture our community.
          </p>
          <p className="mb-12">
            If you see Jonathan around, say hello! He&apos;d love to chat, hear
            your story, and learn how we can make Exercism even better for you
            👇
          </p>
          <div className="flex flex-row items-center bg-backgroundColorA rounded-100 p-12">
            <img
              src={jonathanImageUrl}
              alt="Photo of Jonathan"
              className="w-[48px] h-[48px] mr-16 rounded-circle"
            />
            <div className="flex flex-col">
              <div className="text-h6 mb-4">Jonathan Middleton</div>
              <div className="text-textColor6 font-medium">
                Community Manager
              </div>
            </div>
          </div>
        </div>
      </div>
    </Modal>
  )
}
