// i18n-key-prefix: index
// i18n-namespace: components/settings/github-syncer/sections/ConnectToGithubSection
import React, { useContext } from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { ConnectModal } from './ConnectModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { csrfToken } from '@/utils/csrf-token'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function ConnectToGithubSection() {
  const { links, isGithubLinked, githubUsername } =
    useContext(GitHubSyncerContext)
  const [isModalOpen, setIsModalOpen] = React.useState(false)
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectToGithubSection'
  )

  return (
    <section>
      <div className="flex flex-col items-center max-w-[500px] mx-auto pb-12">
        <div className="flex gap-20 items-center mb-8">
          <Icon
            icon="exercism-face"
            category="icons"
            alt={t('index.exercismAlt')}
            className="mb-16 h-[128px]"
          />
          <Icon
            icon="sync"
            category="graphics"
            alt={t('index.syncWithAlt')}
            className="mb-16 h-[90px]"
          />
          <Icon
            icon="external-site-github"
            category="icons"
            alt={t('index.githubAlt')}
            className="mb-16 h-[128px]"
          />
        </div>
        <h2 className="!text-[30px] !mb-4">
          {t('index.backupYourSolutionsToGithub')}
        </h2>
        <p className="text-[19px] leading-140 mb-16 text-balance text-center">
          {t('index.automatedBackupDescription')}
        </p>
        <div className="flex gap-10 text-15 font-semibold">
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="safe-duo" className="h-[20px]" />
            {t('index.safeBackup')}
          </div>
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="gh-duo" className="h-[20px]" />
            {t('index.greenSquares')}
          </div>
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="free-duo" className="h-[20px]" />
            {t('index.itsFree')}
          </div>
        </div>
        <GraphicalIcon icon="arrow-down-duo" className="h-[32px] my-32" />

        <ol className="w-full text-[18px] leading-140 mb-16">
          <li className="relative mb-16 border-1 border-borderColor6 rounded-8 py-16 ps-[72px] pe-20">
            <GraphicalIcon
              icon="1-duo.svg"
              className="h-[32px] !absolute start-[20px] top-[16px]"
            />
            <h3 className="text-h5 mb-4">{t('index.connectYourAccount')}</h3>
            {isGithubLinked ? (
              <p
                className="flex items-center gap-8 text-16 leading-140 font-semibold"
                data-testid="github-account-linked"
              >
                <GraphicalIcon icon="green-check" className="h-[20px]" />
                {githubUsername
                  ? t('index.accountLinkedAs', { username: githubUsername })
                  : t('index.accountLinked')}
              </p>
            ) : (
              <>
                <p className="text-16 leading-140 mb-12">
                  {t('index.accountMustBeLinked')}
                </p>
                <form method="post" action={links.linkGithub}>
                  <input
                    type="hidden"
                    name="authenticity_token"
                    value={csrfToken()}
                  />
                  <button type="submit" className="btn btn-m btn-primary">
                    {t('index.linkGithubAccount')}
                  </button>
                </form>
              </>
            )}
          </li>

          <li
            className={assembleClassNames(
              'relative border-1 border-borderColor6 rounded-8 py-16 ps-[72px] pe-20',
              isGithubLinked ? '' : 'opacity-60'
            )}
          >
            <GraphicalIcon
              icon="2-duo.svg"
              className="h-[32px] !absolute start-[20px] top-[16px]"
            />
            <h3 className="text-h5 mb-4">{t('index.setUpTheBackup')}</h3>
            {isGithubLinked ? (
              <>
                <p className="text-16 leading-140 mb-8">
                  {t('index.createGithubRepository')}
                </p>
                <p className="text-16 leading-140 mb-8">
                  {t('index.backupEverythingOption')}
                </p>
                <p className="text-16 leading-140 mb-12">
                  {t('index.futureSolutionsAutoBackup')}
                </p>
                <button
                  className="btn btn-m btn-primary w-fit"
                  onClick={() => setIsModalOpen(true)}
                >
                  {t('index.setupBackup')}
                </button>
              </>
            ) : (
              <>
                <p className="text-16 leading-140 mb-12">
                  {t('index.completeStepOneFirst')}
                </p>
                <button className="btn btn-m btn-primary w-fit" disabled>
                  {t('index.setupBackup')}
                </button>
              </>
            )}
          </li>
        </ol>
      </div>
      <ConnectModal onClose={() => setIsModalOpen(false)} open={isModalOpen} />
    </section>
  )
}
