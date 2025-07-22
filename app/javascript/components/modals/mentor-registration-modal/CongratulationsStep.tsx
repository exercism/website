// i18n-key-prefix: congratulationsStep
// i18n-namespace: components/modals/mentor-registration-modal
import React from 'react'
import { GraphicalIcon, Icon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Links = {
  video: string
  dashboard: string
}

export const CongratulationsStep = ({
  links,
}: {
  links: Links
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/mentor-registration-modal')
  return (
    <section className="celebrate-section">
      <GraphicalIcon icon="confetti" category="graphics" />
      <h2>{t('congratulationsStep.youAreNowMentor')}</h2>
      <h3>{t('congratulationsStep.thankYouGrateful')}</h3>
      <p className="welcome">
        {t('congratulationsStep.makeGettingStartedEasy')}
      </p>
      <div className="video-frame">
        <header className="video-header">
          <Icon icon="video" alt="This is a video" />
          <div className="info">
            <h3>{t('congratulationsStep.welcomeToMentorTeam')}</h3>
            <p>{t('congratulationsStep.video')}</p>
          </div>
        </header>
        <div
          className="video"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src={links.video}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
            }}
            frameBorder="0"
            allow="autoplay; fullscreen; picture-in-picture"
            allowFullScreen
          ></iframe>
        </div>
        <script src="https://player.vimeo.com/api/player.js"></script>
      </div>
      <a href={links.dashboard} className="btn-primary btn-m">
        {t('congratulationsStep.readyToGetStarted')}
      </a>
    </section>
  )
}
