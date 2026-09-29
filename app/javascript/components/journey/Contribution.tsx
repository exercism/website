import React from 'react'
import { Trans } from 'react-i18next'
import { fromNow } from '@/utils/date'
import { GraphicalIcon, TrackIcon, Reputation } from '@/components/common'
import { missingExerciseIconErrorHandler } from '@/components/common/imageErrorHandler'
import { Contribution as ContributionProps } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Contribution = ({
  value,
  text,
  iconUrl,
  internalUrl,
  externalUrl,
  createdAt,
  track,
}: ContributionProps): JSX.Element => {
  const url = internalUrl || externalUrl
  const linkIcon = url === internalUrl ? 'chevron-right' : 'external-link'
  const { t } = useAppTranslation('components/journey')

  return (
    <a href={url} className="reputation-token">
      <img
        alt=""
        src={iconUrl}
        className="c-icon primary-icon"
        onError={missingExerciseIconErrorHandler}
      />
      <div className="info">
        <div className="title" dangerouslySetInnerHTML={{ __html: text }} />
        <div className="extra">
          {track ? (
            <div className="exercise">
              <Trans
                ns="components/journey"
                i18nKey="contribution.inTrack"
                values={{ track: track.title }}
                components={[
                  <TrackIcon
                    iconUrl={track.iconUrl}
                    title={track.title}
                    className="primary-icon"
                  />,
                  <div className="name" />,
                ]}
              />
            </div>
          ) : (
            <div className="generic">{t('contribution.generic')}</div>
          )}
          <time dateTime={createdAt}>{fromNow(createdAt)}</time>
        </div>
      </div>
      <Reputation value={`+ ${value}`} type="primary" />
      <GraphicalIcon icon={linkIcon} className="action-button" />
    </a>
  )
}
