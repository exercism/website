import React, { useState } from 'react'
import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(RelativeTime)
import { usePopper } from 'react-popper'

export function Conversation({
  trackTitle,
  trackIconUrl,
  menteeAvatarUrl,
  menteeHandle,
  exerciseTitle,
  isStarred,
  haveMentoredPreviously,
  isNewIteration,
  postsCount,
  updatedAt,
  url,
}) {
  const [referenceElement, setReferenceElement] = useState(null)
  const [popperElement, setPopperElement] = useState(null)
  const [showPopper, setShowPopper] = useState(null)
  const { styles, attributes } = usePopper(referenceElement, popperElement)

  return (
    <>
      <tr
        ref={setReferenceElement}
        onMouseEnter={() => {
          setShowPopper(true)
        }}
        onMouseLeave={() => {
          setShowPopper(null)
        }}
      >
        <td>
          <img
            style={{ width: 100 }}
            src={trackIconUrl}
            alt={`icon for ${trackTitle} track`}
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
        <td>{isNewIteration.toString()}</td>
        <td>{postsCount}</td>
        <td>{dayjs(updatedAt).fromNow()}</td>
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
