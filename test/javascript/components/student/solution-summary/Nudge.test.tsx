import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Nudge } from '../../../../../app/javascript/components/student/solution-summary/Nudge'

test('does not animate on initial load', async () => {
  const { container } = render(
    <Nudge
      status="started"
      mentoringStatus="requested"
      isConceptExercise={false}
      discussions={[]}
      links={{
        mentoringInfo: '',
        completeExercise: '',
        requestMentoring: '',
        shareMentoring: '',
        pendingMentorRequest: '',
      }}
      track={{
        title: 'Ruby',
        medianWaitTime: '7 days',
      }}
    />
  )

  expect(container.firstChild).toHaveAttribute(
    'class',
    'mentoring-request-nudge'
  )
})
