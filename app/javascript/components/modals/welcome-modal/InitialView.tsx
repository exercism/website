import React, { useContext } from 'react'
import { WelcomeModalContext } from './WelcomeModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function InitialView() {
  const { t } = useAppTranslation('components/modals/welcome-modal')
  const { setCurrentView, patchUserSeniority } = useContext(WelcomeModalContext)
  return (
    <div className="lhs">
      <header>
        <h1 className="text-center">{t('initialView.welcomeToExercism')}</h1>

        <p className="text-center">{t('initialView.letsMakeSure')}</p>
        <p className="text-center">{t('initialView.howExperienced')}</p>
      </header>

      <div className="flex flex-col items-stretch gap-8">
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => {
            setCurrentView('beginner')
            patchUserSeniority.mutate('absolute_beginner')
          }}
        >
          {t('initialView.absoluteBeginner')}
        </button>
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => {
            setCurrentView('beginner')
            patchUserSeniority.mutate('beginner')
          }}
        >
          {t('initialView.beginner')}
        </button>
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => {
            setCurrentView('developer')
            patchUserSeniority.mutate('junior')
          }}
        >
          {t('initialView.juniorDeveloper')}
        </button>
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => {
            setCurrentView('developer')
            patchUserSeniority.mutate('mid')
          }}
        >
          {t('initialView.midLevelDeveloper')}
        </button>{' '}
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => {
            setCurrentView('developer')
            patchUserSeniority.mutate('senior')
          }}
        >
          {t('initialView.seniorDeveloper')}
        </button>
      </div>
    </div>
  )
}
