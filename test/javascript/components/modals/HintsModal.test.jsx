import React from 'react'
import { fireEvent, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { HintsModal } from '../../../../app/javascript/components/modals/HintsModal'

test('general hints do not require clicking on heading where there are no task hints', async () => {
  const { getByText } = render(
    <div>
      <HintsModal
        assignment={{
          generalHints: ['Please use the docs', 'It is recommended'],
          tasks: [],
        }}
        open={true}
        ariaHideApp={false}
      />
    </div>
  )

  const generalHeading = getByText('General')
  expect(generalHeading).toBeVisible()
  expect(getByText('Please use the docs')).toBeVisible()
  expect(getByText('It is recommended')).toBeVisible()
})

test('general hints are shown when heading is clicked', async () => {
  const { getByText } = render(
    <div>
      <HintsModal
        assignment={{
          generalHints: ['Please use the docs', 'It is recommended'],
          tasks: [
            {
              title: 'Do complex task',
              hints: ['Really you should!', 'I am sure'],
            },
          ],
        }}
        open={true}
        ariaHideApp={false}
      />
    </div>
  )

  const generalHeading = getByText('General')
  expect(generalHeading).toBeVisible()

  fireEvent.click(generalHeading)
  expect(getByText('Please use the docs')).toBeVisible()
  expect(getByText('It is recommended')).toBeVisible()
})

test('task hints are shown when heading is clicked', async () => {
  const { getByText } = render(
    <div>
      <HintsModal
        assignment={{
          generalHints: [],
          tasks: [
            {
              title: 'Do complex task',
              hints: ['Really you should!', 'I am sure'],
            },
          ],
        }}
        open={true}
        ariaHideApp={false}
      />
    </div>
  )

  const taskheading = getByText('1. Do complex task')
  expect(taskheading).toBeVisible()

  fireEvent.click(taskheading)
  expect(getByText('Really you should!')).toBeVisible()
  expect(getByText('I am sure')).toBeVisible()
})
