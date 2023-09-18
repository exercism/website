import React from 'react'
import { ConceptIcon } from '../ConceptIcon'
import { TrackIcon } from '../TrackIcon'
import { SiteUpdate as SiteUpdateProps, SiteUpdateContext } from '../../types'
import { missingExerciseIconErrorHandler } from '../imageErrorHandler'

export const SiteUpdateIcon = ({
  context,
  track,
  icon,
}: { context: SiteUpdateContext } & Pick<
  SiteUpdateProps,
  'track' | 'icon'
>): JSX.Element => {
  switch (context) {
    case 'track':
      return <TrackIcon iconUrl={track.iconUrl} title={track.title} />
    case 'update':
      switch (icon.type) {
        case 'image':
          return (
            <img
              className="c-icon"
              src={icon.url}
              onError={missingExerciseIconErrorHandler}
            />
          )
        case 'concept':
          return <ConceptIcon size="large" name={icon.data} />
      }
  }
}
