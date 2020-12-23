import React from 'react'
import { fireEvent, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TaskHintsModal } from '../../../../app/javascript/components/modals/TaskHintsModal'

test('task hints are shown', async () => {
  const { getByText } = render(
    <div>
      <TaskHintsModal
        task={{
          title: 'Do complex task',
          hints: ['Really you should!', 'I am sure'],
        }}
        open={true}
        ariaHideApp={false}
      />
    </div>
  )

  expect(getByText('Really you should!')).toBeVisible()
  expect(getByText('I am sure')).toBeVisible()
})
