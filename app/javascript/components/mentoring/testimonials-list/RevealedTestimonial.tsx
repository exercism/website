import React from 'react'
import { fromNow } from '../../../utils/time'
import { Avatar, GraphicalIcon, TrackIcon } from '../../common'
import { Testimonial } from '../../types'

export const RevealedTestimonial = ({
  track,
  student,
  exercise,
  content,
  createdAt,
}: Testimonial): JSX.Element => {
  return (
    <div className="testimonial">
      <TrackIcon {...track} />
      <Avatar src={student.avatarUrl} handle={student.handle} />
      <div className="info">
        <div className="student">{student.handle}</div>
        <div className="exercise">
          on {exercise.title} in {track.title}
        </div>
      </div>
      <div className="content">{content}</div>
      <time dateTime={createdAt}>{fromNow(createdAt)}</time>
      <GraphicalIcon icon="modal" className="action-icon" />
    </div>
  )
}
