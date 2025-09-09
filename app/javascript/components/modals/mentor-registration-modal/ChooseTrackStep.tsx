// i18n-key-prefix: chooseTrackStep
// i18n-namespace: components/modals/mentor-registration-modal
import React from 'react'
import { TrackSelector } from '../../mentoring/TrackSelector'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export type Links = {
  tracks: string
}

export const ChooseTrackStep = ({
  links,
  selected,
  setSelected,
  onContinue,
}: {
  links: Links
  selected: string[]
  setSelected: (selected: string[]) => void
  onContinue: () => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/mentor-registration-modal')
  return (
    <section className="tracks-section">
      <h2>{t('chooseTrackStep.selectTracks')}</h2>
      <p>
        {
          <Trans
            i18nKey="chooseTrackStep.allowsUsToShow"
            ns="components/modals/mentor-registration-modal"
            components={[<strong />]}
          />
        }
      </p>
      <TrackSelector
        tracksEndpoint={links.tracks}
        selected={selected}
        setSelected={setSelected}
        onContinue={onContinue}
      />
    </section>
  )
}
