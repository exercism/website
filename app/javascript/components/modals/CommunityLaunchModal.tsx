import React, { useCallback, useState } from 'react'
import { Modal, ModalProps } from './Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { Avatar, FormButton, GraphicalIcon } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'
import { User } from '../types'

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
      onClose={() => {}}
      className="m-community-launch"
    >
      <div className="lhs">
        <header>
          <h1>Exercism Community</h1>

          <p>
            Exercism&apos;s always been about community - the volunteers who
            create the tracks, the mentors that make learning magic, and
            everyone using the platform to upskill. Now, for the first time,
            we&apos;re doubling down on that community - bringing everyone
            together to learn and support each other.
          </p>
        </header>

        <h2>So, what’s new?</h2>
        <p>
          We’ve added a few new sections to Exercism. Everything is accessible
          via the new Community tab.
        </p>

        <div className="improvements">
          <div className="improvement">
            <GraphicalIcon icon="exercise" category="graphics" />
            <div className="info">
              <h3>Exercism&apos;s Forum</h3>
              <p>
                Want to explore a concept or exercise with others? Want to chat
                about how Exercism can be improved? Want to discuss programming
                in general? Or maybe you just want to get to know the community
                better. Our new forum is the place to go!
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="editor" category="graphics" />
            <div className="info">
              <h3>SWAG</h3>
              <p>
                People have been asking us for SWAG forever. Well now its here!
                T-shirts, hoodies, bags, jigsaws, even phone cases - show your
                love for Exercism with some high-quality merch.
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="reputation" category="graphics" />
            <div className="info">
              <h3>Community Stories</h3>
              <p>
                When you&apos;re feeling frustrated or want some inspriation,
                there&apos;s nothing better than hearing other people&apos;s
                stories. Well now you can sit back and enjoy inspiring tales
                from Exercism&apos;s community in our new Community Stories
                section.
              </p>
            </div>
          </div>
          <div className="improvement">
            <GraphicalIcon icon="journey" category="graphics" />
            <div className="info">
              <h3>Dig Deeper</h3>
              <p>
                There are thousands of videos about solving Exercism&apos;s
                exercises. We&apos;re bringing them all into one place along
                with commentry and guidance on exercises. Look out for the new
                Dig Deeper tab when you complete an exercise!
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
            src="https://www.youtube-nocookie.com/embed/VJ5XkzbG-BI"
            title="YouTube video player"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <script src="https://player.vimeo.com/api/player.js"></script>
        <div className="thank-you">
          <h3>This wouldn't be possible without your kind donations 💙</h3>
          <p className="mb-8">
            Thanks to your kind donations, we've been able to hire Jonathan, our
            new Community Manager, who can now dedicate the time and resource we
            need to properly nuture our community.
          </p>
          <p className="mb-8">
            If you see Jonathan around, say hello! He'd love to chat, hear your
            story, and learn how we can make Exercism even better for you 👇
          </p>
          <div className="flex flex-row items-center bg-white rounded-100 p-12">
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
