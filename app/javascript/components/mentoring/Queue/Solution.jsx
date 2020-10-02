import React, { useState } from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon } from '../../common/TrackIcon'
import { usePopper } from 'react-popper'

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
}) {
  const [referenceElement, setReferenceElement] = useState(null)
  const [popperElement, setPopperElement] = useState(null)
  const [showPopper, setShowPopper] = useState(false)
  const { styles, attributes } = usePopper(referenceElement, popperElement)

  return (
    <>
      <tr
        ref={setReferenceElement}
        onMouseEnter={() => setShowPopper(true)}
        onMouseLeave={() => setShowPopper(false)}
      >
        <td>
          <TrackIcon track={{ title: trackTitle, iconUrl: trackIconUrl }} />
          <img
            style={{ width: 100 }}
            src={trackIconUrl}
            alt={`icon indicating ${trackTitle}`}
          />
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
      {showPopper && (
        <div
          ref={setPopperElement}
          style={styles.popper}
          {...attributes.popper}
        >
          Lorem ipsum
        </div>
      )}
    </>
  )
}
