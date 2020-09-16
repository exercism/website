import React from 'react'
import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(RelativeTime)

function MentorSolutionsListRow({
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
      <td>{status}</td>
      <td>{dayjs(updatedAt).fromNow()}</td>
      <td>{url}</td>
    </tr>
  )
}

export function MentorSolutionsList({ solutions }) {
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
          <th>Status</th>
          <th>Updated at</th>
          <th>URL</th>
        </tr>
      </thead>
      <tbody>
        {solutions.map((solution, key) => (
          <MentorSolutionsListRow key={key} {...solution} />
        ))}
      </tbody>
    </table>
  )
}
