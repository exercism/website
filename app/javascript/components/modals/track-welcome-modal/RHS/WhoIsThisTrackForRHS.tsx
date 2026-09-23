import React from 'react'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { Icon } from '@/components/common'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function WhoIsThisTrackForRHS(): JSX.Element {
  const { t } = useAppTranslation('components/modals/track-welcome-modal/RHS')

  return (
    <div className="rhs" data-capy-element="who-is-this-track-for-rhs">
      <div className="bg-bootcamp-light-purple px-24 pt-28 pb-24 text-center rounded-12 relative">
        <GraphicalIcon
          icon="bookmark.png"
          category="graphics"
          className="!absolute right-[12px] top-0 h-[40px]"
        />
        <h3 className="mb-12 !text-[19px] text-textColor1 font-semibold">
          {t('whoIsThisTrackFor.learnByDoing')}
        </h3>
        <p className="mb-12 !text-16 leading-150">
          {t('whoIsThisTrackFor.youllBuildGames')}
        </p>

        <div className="grid grid-cols-4 gap-4">
          <Icon
            category="bootcamp"
            alt={t('whoIsThisTrackFor.gameAlt.spaceInvaders')}
            icon="space-invaders.gif"
            className="w-full border-1 border-bootcamp-purple"
          />
          <Icon
            category="bootcamp"
            alt={t('whoIsThisTrackFor.gameAlt.ticTacToe')}
            icon="tic-tac-toe.gif"
            className="w-full border-1 border-bootcamp-purple"
          />
          <Icon
            category="bootcamp"
            alt={t('whoIsThisTrackFor.gameAlt.breakout')}
            icon="breakout.gif"
            className="w-full border-1 border-bootcamp-purple"
          />
          <Icon
            category="bootcamp"
            alt={t('whoIsThisTrackFor.gameAlt.maze')}
            icon="maze.gif"
            className="w-full border-1 border-bootcamp-purple"
          />
        </div>

        <hr className="c-divider --small mt-16 mb-8 mx-auto !filter-purple" />
        <p className="mb-6 !text-15 italic leading-150">
          {t('whoIsThisTrackFor.testimonial')}
        </p>
        <p className="mb-!text-15 italic">
          {t('whoIsThisTrackFor.betaTester')}
        </p>
      </div>
    </div>
  )
}
