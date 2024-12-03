import React, { useContext } from 'react'
import { Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { SenioritySurveyModalContext } from './SenioritySurveyModal'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export function BootcampAdvertismentView() {
  const { patchCloseModal } = useContext(SenioritySurveyModalContext)
  return (
    <>
      <div className="lhs">
        <header>
          <h1>Have you heard about the Bootcamp?</h1>

          <p className="mb-8">
            In January, we're running a one-off{' '}
            <strong className="font-semibold text-softEmphasis">
              part-time, remote bootcamp for beginners! 🎉
            </strong>
          </p>
          <p className="mb-8">
            We're going to teach you all the fundamentals with a hands-on
            project-based approach. No stuffy videos, no heavy theory, just lots
            of fun coding!
          </p>
          <p className="mb-8">
            It's super affordable, with discounts if you're a student,
            unemployed, or live in a country with an emerging economy.
          </p>
          <p className="mb-20">Watch our intro video to learn more 👉</p>
        </header>
        <div className="flex gap-8">
          <a
            href="https://bootcamp.exercism.org"
            className="btn-primary btn-l cursor-pointer"
          >
            Go to the Bootcamp ✨
          </a>

          <FormButton
            status={patchCloseModal.status}
            className="btn-secondary btn-l"
            type="button"
            onClick={patchCloseModal.mutate}
          >
            Skip &amp; Close
          </FormButton>
        </div>
        <ErrorBoundary resetKeys={[patchCloseModal.status]}>
          <ErrorMessage
            error={patchCloseModal.error}
            defaultError={DEFAULT_ERROR}
          />
        </ErrorBoundary>
      </div>
      <div className="rhs pt-72">
        <div className="flex flex-row gap-8 items-center justify-center text-16 text-textColor1 mb-16">
          <Icon
            icon="exercism-face"
            className="filter-textColor1"
            alt="exercism-face"
            height={16}
            width={16}
          />
          <div>
            <strong className="font-semibold"> Exercism </strong>
            Bootcamp
          </div>
        </div>
        <div
          className="video relative rounded-8 overflow-hidden !mb-16"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src="https://player.vimeo.com/video/1024390839?h=c2b3bdce14&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479"
            title="Introducing the Exercism Bootcamp"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <div className="bubbles">
          <div className="bubble">
            <Icon category="bootcamp" alt="wave-icon" icon="wave" />
            <div className="text">
              <strong>Live</strong> teaching
            </div>
          </div>
          <div className="bubble">
            <Icon category="bootcamp" alt="fun-icon" icon="fun" />
            <div className="text">
              <strong>Fun</strong> projects
            </div>
          </div>
          <div className="bubble">
            <Icon category="bootcamp" alt="price-icon" icon="price" />
            <div className="text">
              Priced <strong>fairly</strong>{' '}
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
