import React from 'react'
import { Avatar } from '@/components/common'
import { EditedBy } from '@/components/student/iterations-list/RepresenterFeedback'
import { BLOCKQUOTE } from './AnalyzerFeedback'
import type { RepresenterFeedback as Props } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const RepresenterFeedback = ({
  html,
  author,
  editor,
}: Props): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/realtime-feedback-modal/feedback-content/found-automated-feedback'
  )
  return (
    <div className="c-automated-feedback representer-feedback">
      <div className={`comment ${BLOCKQUOTE}`}>
        <div
          className="c-textual-content --small"
          dangerouslySetInnerHTML={{ __html: html }}
        />
      </div>
      <div className="feedback-header">
        <Avatar
          src={author.avatarUrl}
          handle={author.name}
          className="place-self-start"
        />
        <div className="info">
          <Trans
            ns="components/modals/realtime-feedback-modal/feedback-content/found-automated-feedback"
            i18nKey="representerFeedback.gaveFeedbackSimilarSolution"
            values={{ author: author.name }}
            components={[<strong className="inline-block" />]}
          />
          <EditedBy editor={editor} author={author} />.
        </div>
      </div>
    </div>
  )
}
