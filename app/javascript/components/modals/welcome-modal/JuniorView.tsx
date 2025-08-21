import React, { useContext } from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { WelcomeModalContext } from './WelcomeModal'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { redirectTo } from '@/utils'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export function JuniorView() {
  const { t } = useAppTranslation('components/modals/welcome-modal')
  const { patchCloseModal, links } = useContext(WelcomeModalContext)
  return (
    <>
      <div className="lhs flex flex-col">
        <header>
          <h1>{t('juniorView.aCourseForYou')}</h1>

          <p className="mb-8">
            <Trans
              ns="components/modals/welcome-modal"
              i18nKey="juniorView.codingFundamentalsDesigned"
              components={{ strong: <strong /> }}
            />
          </p>
          <p className="mb-8">
            <Trans
              ns="components/modals/welcome-modal"
              i18nKey="juniorView.itWillTeach"
              components={{ strong: <strong /> }}
            />
          </p>
          <div className="grid grid-cols-4 gap-10 mb-12">
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
          <p>
            <Trans
              ns="components/modals/welcome-modal"
              i18nKey="juniorView.thisIsCourseAnyone"
              components={{
                strong: (
                  <strong className="text-backgroundColorH font-semibold" />
                ),
              }}
            />
          </p>
        </header>
        <div className="flex gap-8 mt-auto">
          <FormButton
            status={patchCloseModal.status}
            className="btn-primary btn-l cursor-pointer flex-grow"
            type="button"
            onClick={() => {
              patchCloseModal.mutate()
              redirectTo(links.codingFundamentalsCourse)
            }}
          >
            <Trans
              ns="components/modals/welcome-modal"
              i18nKey="juniorView.learnMore"
              components={{
                strong: (
                  <strong className="text-backgroundColorH font-semibold" />
                ),
              }}
            />
          </FormButton>

          <FormButton
            status={patchCloseModal.status}
            className="btn-secondary btn-l flex-shrink-0 min-w-[140px]"
            type="button"
            onClick={patchCloseModal.mutate}
          >
            {t('juniorView.skip')}
          </FormButton>
        </div>
        <ErrorBoundary resetKeys={[patchCloseModal.status]}>
          <ErrorMessage
            error={patchCloseModal.error}
            defaultError={DEFAULT_ERROR}
          />
        </ErrorBoundary>
      </div>
      <div className="rhs">
        <div className="rounded-8 p-20 bg-backgroundColorD border-1 border-borderColor7">
          <div className="flex flex-row gap-8 items-center justify-center text-16 text-textColor1 mb-16">
            <Icon
              icon="exercism-face"
              className="filter-textColor1"
              alt="exercism-face"
              height={16}
              width={16}
            />
            <div>
              {' '}
              <Trans
                ns="components/modals/welcome-modal"
                i18nKey="juniorView.exercismsCodingFundamentals"
                components={{
                  strong: (
                    <strong className="text-backgroundColorH font-semibold" />
                  ),
                }}
              />
            </div>
          </div>
          <VimeoEmbed
            className="rounded-8 mb-16"
            id="1068683543?h=2de237a304"
          />
          <div className="text-16 leading-150 text-textColor2">
            <p className="mb-8 text-17 font-semibold">
              {t('juniorView.theCourseOffers')}
            </p>
            <ul className="flex flex-col gap-6 text-16 font-regular">
              <li className="flex items-start">
                <GraphicalIcon
                  icon="wave"
                  category="bootcamp"
                  className="mr-8 w-[20px]"
                />
                <span>
                  <Trans
                    ns="components/modals/welcome-modal"
                    i18nKey="juniorView.expertTeaching"
                    components={{
                      strong: (
                        <strong className="text-backgroundColorH font-semibold" />
                      ),
                    }}
                  />
                </span>
              </li>
              <li className="flex items-start">
                <GraphicalIcon
                  icon="fun"
                  category="bootcamp"
                  className="mr-8 w-[20px]"
                />
                <span>
                  {' '}
                  <Trans
                    ns="components/modals/welcome-modal"
                    i18nKey="juniorView.overHoursHandsOn"
                    components={{
                      strong: (
                        <strong className="text-backgroundColorH font-semibold" />
                      ),
                    }}
                  />
                </span>
              </li>
              <li className="flex items-start">
                <GraphicalIcon
                  icon="complete"
                  category="bootcamp"
                  className="mr-8 w-[20px]"
                />
                <span>
                  {' '}
                  <Trans
                    ns="components/modals/welcome-modal"
                    i18nKey="juniorView.aCompleteCoding"
                    components={{
                      strong: (
                        <strong className="text-backgroundColorH font-semibold" />
                      ),
                    }}
                  />
                </span>
              </li>
              <li className="flex items-start">
                <GraphicalIcon
                  icon="certificate"
                  category="bootcamp"
                  className="mr-8 w-[20px]"
                />
                <span>
                  {' '}
                  <Trans
                    ns="components/modals/welcome-modal"
                    i18nKey="juniorView.aFormalCertificate"
                    components={{
                      strong: (
                        <strong className="text-backgroundColorH font-semibold" />
                      ),
                    }}
                  />
                </span>
              </li>
            </ul>
          </div>

          {/*
        <div className="bubbles">
          <div className="bubble">
            <Icon category="bootcamp" alt="wave-icon" icon="video-tutorial" />
            <div className="text">
              <strong>Video</strong> tutorials
            </div>
          </div>
          <div className="bubble">
            <Icon category="bootcamp" alt="fun-icon" icon="fun" />
            <div className="text">
              <strong>Fun</strong> projects
            </div>
          </div>
          <div className="bubble">
            <Icon category="bootcamp" alt="help-icon" icon="help" />
            <div className="text">
              Helpful <strong>mentors</strong>
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
                I was brand new to coding and this course{' '}
                <strong>exceeded my wildest expectations</strong>. In my humble
                opinion, it will be{' '}
                <strong>one of the best choices you will ever make!</strong>
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
                <div className="description">Absolute Beginner</div>
              </div>
              <Icon
                category="bootcamp/testimonials"
                alt="Picture of shaun"
                icon="shaun.jpg"
              />
            </div>
          </div>
        </div>*/}
        </div>
      </div>
    </>
  )
}
