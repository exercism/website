// i18n-key-prefix: videoRHS
// i18n-namespace: components/modals/track-welcome-modal/RHS
import React from 'react'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { Track } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function VideoRHS({ track }: { track: Track }): JSX.Element {
  const { t } = useAppTranslation('components/modals/track-welcome-modal/RHS')

  return (
    <div className="rhs">
      <div className="rounded-8 p-20 bg-backgroundColorD border-1 border-borderColor7">
        <VimeoEmbed
          className="rounded-8 mb-16"
          id={
            track.course ? '903381063?h=bb0a6316bf' : '903384161?h=91c7b9a795'
          }
        />
        <span className="font-medium text-16 leading-150">
          {t('videoRHS.watchThisShortVideo')}
        </span>
      </div>
    </div>
  )
}
