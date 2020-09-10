import React from 'react'
import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(RelativeTime)

function MentorConversationListRow({
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
  return (
    <tr>
      <td>
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
      <td>{isNewIteration.toString()}</td>
      <td>{postsCount}</td>
      <td>{dayjs(updatedAt).fromNow()}</td>
      <td>{url}</td>
    </tr>
  )
}

export function MentorConversationsList({ conversations }) {
  return (
    <table>
      <thead>
        <tr>
          <th>Track icon</th>
          <th>Mentee avatar</th>
          <th>Mentee handle</th>
          <th>Exercise title</th>
          <th>Starred?</th>
          <th>Mentored previously?</th>
          <th>New iteration?</th>
          <th>Posts count</th>
          <th>Updated at</th>
          <th>URL</th>
        </tr>
      </thead>
      <tbody>
        {conversations.map((conversation, key) => (
          <MentorConversationListRow key={key} {...conversation} />
        ))}
      </tbody>
    </table>
  )
}
