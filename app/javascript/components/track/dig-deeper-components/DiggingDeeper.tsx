// i18n-key-prefix: diggingDeeper
// i18n-namespace: components/track/dig-deeper-components
import React from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import Credits from '@/components/common/Credits'
import { User } from '@/components/types'
import { NoIntroductionYet } from '.'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type ApproachIntroduction = {
  html: string
  users: User[]
  links: {
    edit: string
  }
  numAuthors: number
  numContributors: number
}

export function DiggingDeeper({
  introduction,
}: {
  introduction: ApproachIntroduction
}): JSX.Element {
  const { t } = useAppTranslation('components/track/dig-deeper-components')

  return (
    <div className="mb-48">
      {introduction.html.length > 0 ? (
        <>
          <section className="shadow-lgZ1 py-20 mb-16 rounded-8 px-20 lg:px-32 lg:py-24 bg-backgroundColorA">
            <h2 className="mb-8 text-h2">{t('diggingDeeper.digDeeper')}</h2>
            <div
              className="c-textual-content --base dig-deeper-introduction"
              dangerouslySetInnerHTML={{ __html: introduction.html }}
            />
          </section>

          <DiggingDeeperFooter introduction={introduction} />
        </>
      ) : (
        <NoIntroductionYet introduction={introduction} />
      )}
    </div>
  )
}

function DiggingDeeperFooter({
  introduction,
}: {
  introduction: ApproachIntroduction
}): JSX.Element {
  const { t } = useAppTranslation('components/track/dig-deeper-components')

  return (
    <footer className="flex items-center justify-between text-textColor6 py-12 mb-48">
      <div className="flex items-center">
        <Credits
          topCount={introduction.numAuthors}
          topLabel={t('diggingDeeper.author')}
          bottomCount={introduction.numContributors}
          bottomLabel={t('diggingDeeper.contributor')}
          className="text-textColor1 font-semibold leading-150"
          users={introduction.users}
        />
      </div>
      <a
        href={introduction.links.edit}
        target="_blank"
        rel="noreferrer"
        className="xs:flex hidden items-center text-black filter-textColor6 leading-160 font-medium"
      >
        <GraphicalIcon
          height={24}
          width={24}
          icon="external-site-github"
          className="mr-12"
        />
        {t('diggingDeeper.editViaGitHub')}
        <Icon
          className="action-icon h-[13px] ml-12"
          icon="new-tab"
          alt={t('diggingDeeper.linkOpensInNewTab')}
        />
      </a>
    </footer>
  )
}
