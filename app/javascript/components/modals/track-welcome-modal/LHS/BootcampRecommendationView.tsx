import React, { useContext } from 'react'
import { TrackContext } from '../TrackWelcomeModal'
import { Icon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function BootcampRecommendationView() {
  const { hideBootcampRecommendationView, links } = useContext(TrackContext)
  const { t } = useAppTranslation('components/modals/track-welcome-modal/LHS')

  return (
    <>
      <h4
        data-capy-element="bootcamp-recommendation-header"
        className="text-h4 mb-8"
      >
        {t('bootcampRecommendation.header')}
      </h4>

      <p className="mb-8">
        <Trans
          ns="components/modals/track-welcome-modal/LHS"
          i18nKey="bootcampRecommendation.tracksAudience"
          components={{
            strong: <strong className="font-semibold text-black" />,
          }}
        />
      </p>

      <p className="mb-8">
        <Trans
          ns="components/modals/track-welcome-modal/LHS"
          i18nKey="bootcampRecommendation.codingJourney"
          components={{
            strong: <strong className="font-semibold text-black" />,
          }}
        />
      </p>

      <p className="mb-6">{t('bootcampRecommendation.youllBuildGames')}</p>

      <div className="grid grid-cols-4 gap-10 mb-16">
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

      <p className="mb-12">
        <Trans
          ns="components/modals/track-welcome-modal/LHS"
          i18nKey="bootcampRecommendation.selfPaced"
          components={{
            strong: <strong />,
          }}
        />
      </p>

      <div className="flex gap-12 items-center w-full">
        <a
          href={links.codingFundamentalsCourse}
          data-capy-element="go-to-bootcamp-button"
          className="btn-m btn-primary flex-grow"
        >
          {t('bootcampRecommendation.cta.checkOutCourse')}
        </a>
        <button
          onClick={hideBootcampRecommendationView}
          className="btn-m btn-secondary"
          data-capy-element="continue-anyway-button"
        >
          {t('bootcampRecommendation.cta.continueAnyway')}
        </button>
      </div>
    </>
  )
}
