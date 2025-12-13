import React, { useContext } from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { SenioritySurveyModalContext } from './SenioritySurveyModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export function BootcampAdvertismentView() {
  const { patchCloseModal, links } = useContext(SenioritySurveyModalContext)
  const { t } = useAppTranslation('components/modals/seniority-survey-modal')

  return (
    <>
      <div className="curtains" />
      <div className="lhs">
        <header className="!mb-24">
          <div className="mt-40 mb-20 text-[60px] text-center">🎉</div>
          <h1 className="!text-[44px] text-center !mb-4 font-spartan !font-bold">
            <Trans
              ns="components/modals/seniority-survey-modal"
              i18nKey="bootcampAd.heading"
              components={{
                strong: (
                  <strong className="font-semibold text-bootcamp-purple" />
                ),
              }}
            />
          </h1>

          <div className="!font-semibold text-18 text-center mb-20">
            <Trans
              ns="components/modals/seniority-survey-modal"
              i18nKey="bootcampAd.subheading"
              components={{ strong: <strong className="font-semibold" /> }}
            />
          </div>

          <p className="mb-20 !leading-150 !text-17 text-center text-balance">
            <Trans
              ns="components/modals/seniority-survey-modal"
              i18nKey="bootcampAd.punchline"
              components={{
                strong: <strong className="text-black font-semibold" />,
              }}
            />
          </p>

          <div className="bg-bootcamp-light-purple px-12 py-12 text-center rounded-8">
            <div className="grid grid-cols-4 gap-10">
              <Icon
                category="bootcamp"
                alt="Image of a space invaders game"
                icon="space-invaders.gif"
                className="w-full"
              />
              <Icon
                category="bootcamp"
                alt="Image of a tic-tac-toe game"
                icon="tic-tac-toe.gif"
                className="w-full"
              />
              <Icon
                category="bootcamp"
                alt="Image of a breakout game"
                icon="breakout.gif"
                className="w-full"
              />
              <Icon
                category="bootcamp"
                alt="Image of a maze game"
                icon="maze.gif"
                className="w-full"
              />
            </div>
          </div>
        </header>

        <div className="flex gap-12 mt-auto flex-grow mb-20">
          <a
            href={links.codingFundamentalsCourse}
            className="btn-primary btn-l cursor-pointer flex-grow"
          >
            {t('bootcampAd.learnMore')}
          </a>
          <FormButton
            status={patchCloseModal.status}
            className="btn-secondary btn-l w-[140px]"
            type="button"
            onClick={patchCloseModal.mutate}
          >
            {t('bootcampAd.close')}
          </FormButton>
        </div>

        <p className="!leading-150 text-center !text-15 text-textColor5">
          <Trans
            ns="components/modals/seniority-survey-modal"
            i18nKey="bootcampAd.offer"
            components={{
              strong: <strong className="text-black font-semibold" />,
            }}
          />
        </p>

        <ErrorBoundary resetKeys={[patchCloseModal.status]}>
          <ErrorMessage
            error={patchCloseModal.error}
            defaultError={DEFAULT_ERROR}
          />
        </ErrorBoundary>
      </div>

      {/*<div className="rhs">
        <div className="font-semibold text-18 text-center mb-16">
          {t('bootcampAd.videoIntro')}
        </div>

        <div
          className="video relative rounded-8 overflow-hidden !mb-16"
          style={{
            padding: '56.25% 0 0 0',
            position: 'relative',
            background: '#333',
          }}
        >
          <iframe
            src="https://player.vimeo.com/video/1068683543?h=2de237a304&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479"
            title="Introducing Coding Fundamentals"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>

        <div className="bubbles">
          <div className="bubble">
            <Icon category="bootcamp" alt="wave-icon" icon="video-tutorial" />
            <div className="text">
              <Trans
                ns="components/modals/seniority-survey-modal"
                i18nKey="bootcampAd.feature.video"
                components={{ strong: <strong /> }}
              />
            </div>
          </div>

          <div className="bubble">
            <Icon category="bootcamp" alt="fun-icon" icon="fun" />
            <div className="text">
              <Trans
                ns="components/modals/seniority-survey-modal"
                i18nKey="bootcampAd.feature.fun"
                components={{ strong: <strong /> }}
              />
            </div>
          </div>

          <div className="bubble">
            <Icon category="bootcamp" alt="help-icon" icon="help" />
            <div className="text">
              <Trans
                ns="components/modals/seniority-survey-modal"
                i18nKey="bootcampAd.feature.mentors"
                components={{ strong: <strong /> }}
              />
            </div>
          </div>
        </div>

        <div className="quote">
          <div className="words">
            <GraphicalIcon
              category="bootcamp"
              icon="quote.png"
              className="mark left-mark"
            />
            <span>
              <p>
                <Trans
                  ns="components/modals/seniority-survey-modal"
                  i18nKey="bootcampAd.quote"
                  components={{ strong: <strong /> }}
                />
              </p>
              <GraphicalIcon
                category="bootcamp"
                icon="quote.png"
                className="mark right-mark"
              />
            </span>
          </div>

          <div className="person">
            <div className="flex flex-row items-center justify-end gap-8">
              <div className="text">
                <div className="name">Shaun</div>
                <div className="description">
                  {t('bootcampAd.quote.description')}
                </div>
              </div>
              <Icon
                category="bootcamp/testimonials"
                alt="Picture of shaun"
                icon="shaun.jpg"
              />
            </div>
          </div>
        </div>
      </div>*/}
    </>
  )
}
