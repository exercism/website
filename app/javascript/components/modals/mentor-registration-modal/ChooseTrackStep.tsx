import React from 'react'
import { TrackSelector } from '../../mentoring/TrackSelector'

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
  return (
    <section className="tracks-section">
      <h2>Select the tracks you want to mentor</h2>
      <p>
        This allows us to only show you the solutions you want to mentor.{' '}
        <strong>
          Don’t worry, you can change these selections at anytime.
        </strong>
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
