// i18n-key-prefix: approaches
// i18n-namespace: components/track/dig-deeper-components
import React, { useContext } from 'react'
import { ApproachSnippet, SectionHeader } from '.'
import { Approach, DigDeeperDataContext } from '../DigDeeper'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function Approaches({
  approaches,
}: {
  approaches: Approach[]
}): JSX.Element {
  const { exercise } = useContext(DigDeeperDataContext)
  const { t } = useAppTranslation('components/track/dig-deeper-components')

  return (
    <div className="lg:flex lg:flex-col mb-24">
      <SectionHeader
        title={t('approaches.approaches')}
        description={
          approaches.length > 0
            ? t('approaches.otherWaysCommunitySolved')
            : t('approaches.noApproaches', { exerciseTitle: exercise.title })
        }
        icon="dig-deeper-gradient"
        className="mb-16"
      />

      <div className="lg:flex lg:flex-col grid grid-cols-1 md:grid-cols-2 gap-x-16 lg:gap-x-[unset]">
        {approaches.length > 0 &&
          approaches.map((i) => {
            return <ApproachSnippet key={i.title} approach={i} />
          })}
      </div>
    </div>
  )
}
