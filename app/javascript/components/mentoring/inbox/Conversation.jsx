import React from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon } from '../../common/TrackIcon'

export function Conversation({
  trackTitle,
  trackIconUrl,
  menteeAvatarUrl,
  menteeHandle,
  exerciseTitle,
  isStarred,
  haveMentoredPreviously,
  isNewSubmission,
  postsCount,
  updatedAt,
  url,
}) {
  return (
    <tr>
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
      <td>{isNewSubmission.toString()}</td>
      <td>{postsCount}</td>
      <td>{fromNow(updatedAt)}</td>
      <td>{url}</td>
    </tr>
  )
}
