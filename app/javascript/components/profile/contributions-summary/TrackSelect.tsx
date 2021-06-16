import React, { useCallback } from 'react'
import { Track, getTotalReputation } from '../ContributionsSummary'
import {
  TrackSelect as BaseTrackSelect,
  TrackLogo,
} from '../../common/TrackSelect'

const OptionComponent = ({ option: track }: { option: Track }): JSX.Element => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="title">{track.title}</div>
      <div className="count">
        {getTotalReputation(track).toLocaleString()} rep
      </div>
    </React.Fragment>
  )
}

const SelectedComponent = ({
  option: track,
}: {
  option: Track
}): JSX.Element => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="track-title">{track.title}</div>
      <div className="count">
        {getTotalReputation(track).toLocaleString()} rep
      </div>
    </React.Fragment>
  )
}

export const TrackSelect = ({
  tracks,
  value,
  setValue,
}: {
  tracks: readonly Track[]
  value: Track
  setValue: (value: Track) => void
}): JSX.Element => {
  const handleSet = useCallback(
    (track) => {
      const matchingTrack = tracks.find((t) => t.id === track.id)

      if (!matchingTrack) {
        throw new Error('No matching track')
      }

      setValue(matchingTrack)
    },
    [setValue, tracks]
  )

  return (
    <BaseTrackSelect<Track>
      tracks={tracks}
      value={value}
      setValue={handleSet}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
