import React from 'react'

export function Track({
  trackTitle,
  trackIconUrl,
  exerciseCount,
  conceptExerciseCount,
  practiceExerciseCount,
  studentCount,
  isNew,
  isJoined,
  tags,
  completedExerciseCount,
  trackProgressPercentage,
  url,
}) {
  return (
    <tr>
      <td>
        <img
          style={{ width: 100 }}
          src={trackIconUrl}
          alt={`icon for ${trackTitle} track`}
        />
      </td>
      <td>{trackTitle}</td>
      <td>{exerciseCount}</td>
      <td>{conceptExerciseCount}</td>
      <td>{practiceExerciseCount}</td>
      <td>{studentCount}</td>
      <td>{isNew.toString()}</td>
      <td>{isJoined.toString()}</td>
      <td>{tags.join(', ')}</td>
      <td>{completedExerciseCount}</td>
      <td>{trackProgressPercentage}</td>
      <td>{url}</td>
    </tr>
  )
}
