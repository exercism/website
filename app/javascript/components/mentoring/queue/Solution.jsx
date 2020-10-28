import React, { useState } from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon } from '../../common/TrackIcon'

export function Solution({
  trackTitle,
  trackIconUrl,
  menteeAvatarUrl,
  menteeHandle,
  exerciseTitle,
  isStarred,
  haveMentoredPreviously,
  status,
  updatedAt,
  url,
  onMouseEnter,
  onMouseLeave,
}) {
  const [referenceElement, setReferenceElement] = useState(null)

  return (
    <tr
      ref={setReferenceElement}
      onMouseEnter={() => onMouseEnter(referenceElement)}
      onMouseLeave={() => onMouseLeave(referenceElement)}
    >
      <td>
        <TrackIcon track={{ title: trackTitle, iconUrl: trackIconUrl }} />
      </td>
      <td>
        <img
          style={{ width: 100 }}
          src={menteeAvatarUrl}
          alt={`avatar for ${menteeHandle}`}
        />
      </td>
      <td>{menteeHandle}</td>
      <td>{exerciseTitle}</td>
      <td>{isStarred.toString()}</td>
      <td>{haveMentoredPreviously.toString()}</td>
      <td>{status}</td>
      <td>{fromNow(updatedAt)}</td>
      <td>{url}</td>
    </tr>
  )
}
