import React from 'react'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const CommunitySolutions = ({
  link,
  isTutorial,
}: {
  link: string
  isTutorial: boolean
}): JSX.Element => {
  const { t } = useAppTranslation('components/student/solution-summary')
  return (
    <div className="community-solutions">
      <GraphicalIcon
        icon="community-solutions"
        category="graphics"
        className="header-icon"
      />
      <h3>{t('communitySolutions.learnFromOthersSolutions')}</h3>
      {isTutorial ? (
        <p>{t('communitySolutions.thisIsWhereWeWouldUsuallyLink')}</p>
      ) : (
        <>
          <p>{t('communitySolutions.exploreTheirApproaches')}</p>
          <a href={link} className="btn-small-discourage">
            {t('communitySolutions.viewCommunitySolutions')}
          </a>
        </>
      )}
    </div>
  )
}
