import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Discussion } from '../../../../app/javascript/components/mentoring/Discussion'

test('highlights currently selected iteration', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
  }
  const iterations = [
    {
      idx: 1,
      links: {
        posts: 'https://exercism.test/iterations/1/posts',
      },
    },
    {
      idx: 2,
      links: {
        posts: 'https://exercism.test/iterations/2/posts',
      },
    },
  ]
  render(
    <Discussion
      exercise={exercise}
      links={links}
      track={track}
      student={student}
      iterations={iterations}
      discussionId={1}
    />
  )

  userEvent.click(screen.getByRole('button', { name: 'Go to iteration 1' }))

  expect(
    await screen.findByRole('button', { name: 'Go to iteration 1' })
  ).toHaveAttribute('aria-current', 'true')
})

test('shows back button', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
  }
  const iterations = [
    {
      idx: 1,
      links: {
        posts: 'https://exercism.test/iterations/1/posts',
      },
    },
  ]
  render(
    <Discussion
      exercise={exercise}
      links={links}
      track={track}
      student={student}
      iterations={iterations}
      discussionId={1}
    />
  )

  expect(
    screen.getByRole('link', { name: 'Back to exercise' })
  ).toHaveAttribute('href', 'https://exercism.test/exercise')
})
