// i18n-key-prefix: solutionCommentTextArea
// i18n-namespace: components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const SolutionCommentTextArea = React.forwardRef<
  HTMLTextAreaElement,
  unknown
>((_, ref) => {
  const { t } = useAppTranslation()
  return (
    <div className="question">
      <label htmlFor="request-mentoring-form-solution-comment">
        {t('solutionCommentTextArea.howCanMentorHelpYou')}
      </label>
      <p id="request-mentoring-form-solution-description">
        {t('solutionCommentTextArea.giveMentorStartingPoint')}
      </p>
      <textarea
        ref={ref}
        id="request-mentoring-form-solution-comment"
        required
        minLength={20}
        aria-describedby="request-mentoring-form-solution-description"
      />
    </div>
  )
})
