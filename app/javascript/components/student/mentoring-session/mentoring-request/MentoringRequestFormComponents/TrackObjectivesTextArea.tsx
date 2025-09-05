// i18n-key-prefix: trackObjectivesTextArea
// i18n-namespace: components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents
import React from 'react'
import type { MentorSessionTrack } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TrackObjectivesTextArea = React.forwardRef<
  HTMLTextAreaElement,
  { defaultValue: string; track: Pick<MentorSessionTrack, 'title'> }
>(({ track, defaultValue }, ref) => {
  const { t } = useAppTranslation()
  return (
    <div className="question">
      <label htmlFor="request-mentoring-form-track-objectives">
        {t('trackObjectivesTextArea.whatAreYouHopingToLearn')}
      </label>
      <p id="request-mentoring-form-track-description">
        {t('trackObjectivesTextArea.tellOurMentorsAboutYourBackground', {
          trackTitle: track.title,
        })}
      </p>
      <textarea
        ref={ref}
        id="request-mentoring-form-track-objectives"
        required
        minLength={20}
        aria-describedby="request-mentoring-form-track-description"
        defaultValue={defaultValue}
      />
    </div>
  )
})
