import React, { useState } from 'react'
import { useDropdown } from './useDropdown'
import { Track } from '../types'
import { Icon, GraphicalIcon } from '../common'
import { ActivatePracticeModeModal } from './track-menu/ActivatePracticeModeModal'
import { ActivateLearningModeModal } from './track-menu/ActivateLearningModeModal'
import { ResetTrackModal } from './track-menu/ResetTrackModal'
import { LeaveTrackModal } from './track-menu/LeaveTrackModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export type Links = {
  repo: string
  documentation: string
  activatePracticeMode?: string
  activateLearningMode?: string
  reset?: string
  leave?: string
}

type ModalType = 'learning' | 'practice' | 'reset' | 'leave'

export default function TrackMenu({
  track,
  links,
  ariaHideApp = false,
}: {
  track: Track
  links: Links
  ariaHideApp?: boolean
}): JSX.Element {
  const { t } = useAppTranslation()
  const [modal, setModal] = useState<ModalType | null>(null)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(5, undefined, {
    placement: 'bottom-start',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  return (
    <div className="c-track-menu">
      <button {...buttonAttributes}>
        <Icon icon="more-horizontal" alt="Track options" />
      </button>
      {open ? (
        <div {...panelAttributes} className="c-dropdown-generic-menu">
          <ul {...listAttributes}>
            <li {...itemAttributes(0)}>
              <a href={links.repo} target="_blank" rel="noreferrer">
                <GraphicalIcon icon="external-site-github" />
                <Trans
                  i18nKey="trackMenu.seeTrackOnGithub"
                  values={{ trackTitle: track.title }}
                  components={{
                    icon: (
                      <GraphicalIcon
                        icon="external-link"
                        className="external-link"
                      />
                    ),
                  }}
                />
              </a>
            </li>
            <li {...itemAttributes(1)}>
              <a href={links.documentation} target="_blank" rel="noreferrer">
                <GraphicalIcon icon="docs" />
                {t('trackMenu.documentation', { trackTitle: track.title })}
              </a>
            </li>
            <li {...itemAttributes(2)}>
              <a href={links.buildStatus}>
                <GraphicalIcon icon="building" />
                {t('trackMenu.trackBuildStatus')}
              </a>
            </li>
            {links.activatePracticeMode ? (
              <li {...itemAttributes(2)}>
                <button type="button" onClick={() => setModal('practice')}>
                  <GraphicalIcon icon="practice-mode" />
                  {t('trackMenu.disableLearningMode')}
                </button>
              </li>
            ) : links.activateLearningMode ? (
              <li {...itemAttributes(2)}>
                <button type="button" onClick={() => setModal('learning')}>
                  <GraphicalIcon icon="concepts" />
                  {t('trackMenu.enableLearningMode')}
                </button>
              </li>
            ) : null}
            {links.reset ? (
              <li {...itemAttributes(3)}>
                <button type="button" onClick={() => setModal('reset')}>
                  <GraphicalIcon icon="reset" />
                  {t('trackMenu.resetTrack')}
                </button>
              </li>
            ) : null}
            {links.leave ? (
              <li {...itemAttributes(4)}>
                <button type="button" onClick={() => setModal('leave')}>
                  <div className="emoji">👋</div>
                  {t('trackMenu.leaveTrack')}
                </button>
              </li>
            ) : null}
          </ul>
        </div>
      ) : null}
      {links.activatePracticeMode ? (
        <ActivatePracticeModeModal
          open={modal === 'practice'}
          onClose={() => setModal(null)}
          endpoint={links.activatePracticeMode}
          ariaHideApp={ariaHideApp}
        />
      ) : null}
      {links.activateLearningMode ? (
        <ActivateLearningModeModal
          open={modal === 'learning'}
          onClose={() => setModal(null)}
          endpoint={links.activateLearningMode}
          ariaHideApp={ariaHideApp}
        />
      ) : null}
      {links.reset ? (
        <ResetTrackModal
          open={modal === 'reset'}
          track={track}
          onClose={() => setModal(null)}
          endpoint={links.reset}
          ariaHideApp={ariaHideApp}
        />
      ) : null}
      {links.leave ? (
        <LeaveTrackModal
          open={modal === 'leave'}
          track={track}
          onClose={() => setModal(null)}
          endpoint={links.leave}
          ariaHideApp={ariaHideApp}
        />
      ) : null}
    </div>
  )
}
