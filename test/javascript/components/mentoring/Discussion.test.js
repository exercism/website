import React from 'react'
import userEvent from '@testing-library/user-event'
import {
  render,
  screen,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Discussion } from '../../../../app/javascript/components/mentoring/Discussion'
import { stubRange } from '../../support/code-mirror-helpers'

stubRange()

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
        files: 'https://exercism.test/iterations/1/files',
      },
    },
    {
      idx: 2,
      links: {
        files: 'https://exercism.test/iterations/2/files',
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
    mentorDashboard: 'https://exercism.test/mentor/dashboard',
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
    posts: 'https://exercism.test/posts',
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
        files: 'https://exercism.test/iterations/1/files',
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
    screen.getByRole('link', {
      name: 'Close discussion and return to mentoring dashboard',
    })
  ).toHaveAttribute('href', 'https://exercism.test/mentor/dashboard')
})

test('hides latest label if on old iteration', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
    posts: 'https://exercism.test/posts',
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
        files: 'https://exercism.test/iterations/1/files',
      },
    },
    {
      idx: 2,
      links: {
        files: 'https://exercism.test/iterations/2/files',
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
  ).toBeDisabled()
  expect(screen.queryByText('latest')).not.toBeInTheDocument()
})

test('switches to posts tab when comment success', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
    posts: 'https://exercism.test/posts',
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
        files: 'https://exercism.test/iterations/1/files',
      },
    },
  ]
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

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

  userEvent.click(screen.getByRole('tab', { name: 'Scratchpad' }))
  userEvent.click(screen.getByRole('button', { name: 'Add a comment' }))
  document
    .querySelector('.comment-section .CodeMirror')
    .CodeMirror.setValue('#Hello')
  userEvent.click(screen.getByRole('button', { name: 'Send' }))

  await waitForElementToBeRemoved(screen.getByRole('button', { name: 'Send' }))

  expect(
    await screen.findByRole('tab', { name: 'Discussion' })
  ).toHaveAttribute('aria-selected', 'true')
  expect(
    screen.queryByRole('tabpanel', { name: 'Discussion' })
  ).toBeInTheDocument()

  server.close()
})

test('switches tabs', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
    posts: 'https://exercism.test/posts',
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
        files: 'https://exercism.test/iterations/1/files',
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

  userEvent.click(screen.getByRole('tab', { name: 'Scratchpad' }))

  expect(
    await screen.findByRole('tab', { name: 'Scratchpad', selected: true })
  ).toBeInTheDocument()
  expect(
    await screen.findByRole('tabpanel', { name: 'Scratchpad' })
  ).toBeInTheDocument()
  expect(
    await screen.findByRole('tab', { name: 'Discussion', selected: false })
  ).toBeInTheDocument()
  expect(
    screen.queryByRole('tabpanel', { name: 'Discussion' })
  ).not.toBeInTheDocument()
})
