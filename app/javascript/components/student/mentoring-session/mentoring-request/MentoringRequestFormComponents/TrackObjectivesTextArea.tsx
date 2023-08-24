import React from 'react'
import type { MentorSessionTrack } from '@/components/types'

export const TrackObjectivesTextArea = React.forwardRef<
  HTMLTextAreaElement,
  { defaultValue: string; track: Pick<MentorSessionTrack, 'title'> }
>(({ track, defaultValue }, ref) => (
  <div className="question">
    <label htmlFor="request-mentoring-form-track-objectives">
      What are you hoping to learn from this track?
    </label>
    <p id="request-mentoring-form-track-description">
      Tell our mentors a little about your programming background and what
      you&apos;re aiming to learn from {track.title}.
    </p>
    <textarea
      ref={ref}
      id="request-mentoring-form-track-objectives"
      required
      aria-describedby="request-mentoring-form-track-description"
      defaultValue={defaultValue}
    />
    <div className="c-alert--danger">Minimum 20 characters required</div>
  </div>
))
