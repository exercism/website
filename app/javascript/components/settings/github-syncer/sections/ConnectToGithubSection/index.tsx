import React from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { ConnectModal } from './ConnectModal'
import { useTranslation } from 'react-i18next'
import { initI18n } from '@/i18n'

initI18n()

export function ConnectToGithubSection() {
  const [isModalOpen, setIsModalOpen] = React.useState(false)
  const { t } = useTranslation('settings/github-syncer')

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
        <h2 className="!text-[30px] !mb-4">{t('connect_section.heading')}</h2>
        <p className="text-[19px] leading-140 mb-16 text-balance text-center">
          {t('connect_section.description')}
        </p>
        <div className="flex gap-10 text-15 font-semibold">
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="safe-duo" className="h-[20px]" />
            {t('connect_section.benefits.safe')}
          </div>
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="gh-duo" className="h-[20px]" />
            {t('connect_section.benefits.green')}
          </div>
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="free-duo" className="h-[20px]" />
            {t('connect_section.benefits.free')}
          </div>
        </div>
        <GraphicalIcon icon="arrow-down-duo" className="h-[32px] my-32" />

        <ol className="text-[18px] leading-140 mb-16 ml-[45px]">
          <li className="mb-16 relative">
            <GraphicalIcon
              icon="1-duo.svg"
              className="h-[32px] !absolute left-[-45px]"
            />
            {t('connect_section.steps.1')}
          </li>

          <li className="mb-16 relative">
            <GraphicalIcon
              icon="2-duo.svg"
              className="h-[32px] !absolute left-[-45px]"
            />
            {t('connect_section.steps.2')}
          </li>

          <li className="mb-16 relative">
            <GraphicalIcon
              icon="3-duo.svg"
              className="h-[32px] !absolute left-[-45px]"
            />
            {t('connect_section.steps.3')}
          </li>

          <li className="mb-16 relative">
            <GraphicalIcon
              icon="4-duo.svg"
              className="h-[32px] !absolute left-[-45px]"
            />
            {t('connect_section.steps.4')}
          </li>
        </ol>
        <button
          className="btn btn-l btn-primary w-fit"
          onClick={() => setIsModalOpen(true)}
        >
          {t('connect_section.button')}
        </button>
      </div>
      <ConnectModal onClose={() => setIsModalOpen(false)} open={isModalOpen} />
    </section>
  )
}
