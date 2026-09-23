import React from 'react'
import { fireEvent, render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import UpdateExerciseNotice from '@/components/student/UpdateExerciseNotice'

jest.mock('@/components/modals/ExerciseUpdateModal', () => ({
  ExerciseUpdateModal: ({ open }: { open: boolean }) =>
    open ? <div>update modal</div> : null,
}))

const links = {
  diff: '/diff',
  english: 'https://exercism.org/tracks/ruby/exercises/bob',
}

test('the usual notice', () => {
  render(<UpdateExerciseNotice links={links} />)

  expect(screen.getByText(/This exercise has been updated/)).toBeInTheDocument()
  expect(screen.queryByText(/newer version/)).not.toBeInTheDocument()
})

test('docs for a newer version offer english, or the existing update flow', () => {
  render(<UpdateExerciseNotice links={links} docsForNewerVersion />)

  expect(
    screen.getByText(
      /These instructions are for a newer version of the exercise/
    )
  ).toBeInTheDocument()
  expect(
    screen.getByRole('link', { name: 'Switch to English' })
  ).toHaveAttribute('href', links.english)

  expect(screen.queryByText('update modal')).not.toBeInTheDocument()
  fireEvent.click(
    screen.getByRole('button', { name: 'Update to the latest version' })
  )
  expect(screen.getByText('update modal')).toBeInTheDocument()
})
