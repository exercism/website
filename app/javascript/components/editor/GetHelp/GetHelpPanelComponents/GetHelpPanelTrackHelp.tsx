// i18n-key-prefix: getHelpPanelComponents.getHelpPanelTrackHelp
// i18n-namespace: components/editor/GetHelp
import React from 'react'
import { GetHelpPanelProps } from '../GetHelpPanel'
import { GetHelpAccordionSkeleton } from './GetHelpAccordionSkeleton'
import { TrackIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function GetHelpPanelTrackHelp({
  helpHtml,
  track,
}: Pick<GetHelpPanelProps, 'helpHtml' | 'track'>): JSX.Element {
  const { t } = useAppTranslation('components/editor/GetHelp')
  return (
    <GetHelpAccordionSkeleton
      title={t('getHelpPanelComponents.getHelpPanelTrackHelp.trackHelp', {
        trackTitle: track.title,
      })}
      icon={
        <TrackIcon
          title={track.title}
          iconUrl={track.iconUrl}
          className="w-[24px] h-[24px] mr-16"
        />
      }
    >
      <div
        className="c-textual-content --base pt-16"
        dangerouslySetInnerHTML={{ __html: helpHtml }}
      />
    </GetHelpAccordionSkeleton>
  )
}
