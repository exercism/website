// i18n-key-prefix: index
// i18n-namespace: components/settings/github-syncer/sections/ConnectToGithubSection
import React from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { ConnectModal } from './ConnectModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function ConnectToGithubSection() {
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
            alt="Exercism"
            className="mb-16 h-[128px]"
          />
          <Icon
            icon="sync"
            category="graphics"
            alt="Sync with"
            className="mb-16 h-[90px]"
          />
          <Icon
            icon="external-site-github"
            category="icons"
            alt="Github"
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

        <ol className="text-[18px] leading-140 mb-16 ml-[45px]">
          <li className="mb-16 relative">
            <GraphicalIcon
              icon="1-duo.svg"
              className="h-[32px] !absolute left-[-45px]"
            />
            {t('index.createGithubRepository')}
          </li>

          <li className="mb-16 relative">
            <GraphicalIcon
              icon="2-duo.svg"
              className="h-[32px] !absolute left-[-45px]"
            />
            {t('index.clickButtonToConnect')}
          </li>

          <li className="mb-16 relative">
            <GraphicalIcon
              icon="3-duo.svg"
              className="h-[32px] !absolute left-[-45px]"
            />
            {t('index.backupEverythingOption')}
          </li>

          <li className="mb-16 relative">
            <GraphicalIcon
              icon="4-duo.svg"
              className="h-[32px] !absolute left-[-45px]"
            />
            {t('index.futureSolutionsAutoBackup')}
          </li>
        </ol>
        <button
          className="btn btn-l btn-primary w-fit"
          onClick={() => setIsModalOpen(true)}
        >
          {t('index.setupBackup')}
        </button>
      </div>
      <ConnectModal onClose={() => setIsModalOpen(false)} open={isModalOpen} />
    </section>
  )
}
