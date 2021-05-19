import React from 'react'
import userEvent from '@testing-library/user-event'
import {
  render,
  screen,
  act,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Session } from '../../../../app/javascript/components/mentoring/Session'
import { stubRange } from '../../support/code-mirror-helpers'
import { awaitPopper } from '../../support/await-popper'
import { queryCache } from 'react-query'
import { expectConsoleError } from '../../support/silence-console'

stubRange()

test('highlights currently selected iteration', async () => {
  const links = {
    scratchpad: 'http://exercism.test/scratchpad',
  }
  const discussion = {
    id: 1,
    links: {
      posts: 'https://exercism.test/posts',
    },
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
    languagesSpoken: [],
    links: {
      favorite: 'https://exercism.test/favorite',
    },
    reputation: 10,
  }
  const iterations = [
    {
      idx: 1,
      links: {
        files: 'https://exercism.test/iterations/1/files',
      },
      createdAt: new Date().toISOString(),
    },
    {
      idx: 2,
      links: {
        files: 'https://exercism.test/iterations/2/files',
      },
      createdAt: new Date().toISOString(),
    },
  ]
  expectConsoleError(async () => {
    render(
      <Session
        exercise={exercise}
        links={links}
        track={track}
        student={student}
        iterations={iterations}
        discussion={discussion}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Go to iteration 1' }))
    queryCache.cancelQueries()

    expect(
      await screen.findByRole('button', { name: 'Go to iteration 1' })
    ).toHaveAttribute('aria-current', 'true')

    await awaitPopper()
  })
})

test('shows back button', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    mentorDashboard: 'https://exercism.test/mentor/dashboard',
    exercise: 'https://exercism.test/exercise',
  }
  const discussion = {
    id: 1,
    links: {
      posts: 'https://exercism.test/posts',
    },
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
    languagesSpoken: [],
    links: {
      favorite: 'https://exercism.test/favorite',
    },
    reputation: 10,
  }
  const iterations = [
    {
      idx: 1,
      links: {
        files: 'https://exercism.test/iterations/1/files',
      },
      createdAt: new Date().toISOString(),
    },
  ]

  render(
    <Session
      exercise={exercise}
      links={links}
      track={track}
      student={student}
      iterations={iterations}
      discussion={discussion}
    />
  )
  queryCache.cancelQueries()

  expect(
    await screen.findByRole('link', {
      name: 'Close discussion and return to mentoring dashboard',
    })
  ).toHaveAttribute('href', 'https://exercism.test/mentor/dashboard')
})

test('hides latest label if on old iteration', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
  }
  const discussion = {
    id: 1,
    links: {
      posts: 'https://exercism.test/posts',
    },
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
    languagesSpoken: [],
    links: {
      favorite: 'https://exercism.test/favorite',
    },
    reputation: 10,
  }
  const iterations = [
    {
      idx: 1,
      links: {
        files: 'https://exercism.test/iterations/1/files',
      },
      createdAt: new Date().toISOString(),
    },
    {
      idx: 2,
      links: {
        files: 'https://exercism.test/iterations/2/files',
      },
      createdAt: new Date().toISOString(),
    },
  ]

  render(
    <Session
      exercise={exercise}
      links={links}
      track={track}
      student={student}
      iterations={iterations}
      discussion={discussion}
    />
  )
  await awaitPopper()
  act(() => {
    userEvent.click(screen.getByRole('button', { name: 'Go to iteration 1' }))
  })
  queryCache.cancelQueries()

  expect(
    await screen.findByRole('button', { name: 'Go to iteration 1' })
  ).toBeDisabled()
  expect(screen.queryByText('latest')).not.toBeInTheDocument()
})

test('switches to posts tab when comment success', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
  }
  const discussion = {
    id: 1,
    links: {
      posts: 'https://exercism.test/posts',
    },
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
    languagesSpoken: [],
    links: {
      favorite: 'https://exercism.test/favorite',
    },
    reputation: 10,
  }
  const iterations = [
    {
      idx: 1,
      links: {
        files: 'https://exercism.test/iterations/1/files',
      },
      createdAt: new Date().toISOString(),
    },
  ]
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({ post: {} }))
    })
  )
  server.listen()

  render(
    <Session
      exercise={exercise}
      links={links}
      track={track}
      student={student}
      iterations={iterations}
      discussion={discussion}
    />
  )

  userEvent.click(screen.getByRole('tab', { name: 'Scratchpad' }))
  userEvent.click(screen.getByRole('button', { name: 'Add a comment' }))
  document
    .querySelector('.comment-section .CodeMirror')
    .CodeMirror.setValue('#Hello')
  const button = screen.getByRole('button', { name: 'Send' })
  userEvent.click(button)

  await waitForElementToBeRemoved(button)
  queryCache.cancelQueries()

  expect(
    await screen.findByRole('tab', { name: 'Discussion' })
  ).toHaveAttribute('aria-selected', 'true')
  expect(
    screen.queryByRole('tabpanel', { name: 'Discussion' })
  ).toBeInTheDocument()

  queryCache.cancelQueries()
  server.close()
})

test('switches tabs', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
  }
  const discussion = {
    id: 1,
    links: {
      posts: 'https://exercism.test/posts',
    },
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
    languagesSpoken: [],
    links: {
      favorite: 'https://exercism.test/favorite',
    },
    reputation: 10,
  }
  const iterations = [
    {
      idx: 1,
      links: {
        files: 'https://exercism.test/iterations/1/files',
      },
      createdAt: new Date().toISOString(),
    },
  ]

  render(
    <Session
      exercise={exercise}
      links={links}
      track={track}
      student={student}
      iterations={iterations}
      discussion={discussion}
    />
  )
  userEvent.click(screen.getByRole('tab', { name: 'Scratchpad' }))
  queryCache.cancelQueries()

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

test('go to previous iteration', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
  }
  const discussion = {
    id: 1,
    links: {
      posts: 'https://exercism.test/posts',
    },
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
    links: {
      favorite: 'https://exercism.test/favorite',
    },
    reputation: 10,
  }
  const iterations = [
    {
      idx: 1,
      links: {
        files: 'https://exercism.test/iterations/1/files',
      },
      createdAt: new Date().toISOString(),
    },
    {
      idx: 2,
      links: {
        files: 'https://exercism.test/iterations/2/files',
      },
      createdAt: new Date().toISOString(),
    },
  ]

  act(() => {
    render(
      <Session
        exercise={exercise}
        links={links}
        track={track}
        student={student}
        iterations={iterations}
        discussion={discussion}
      />
    )
  })
  await awaitPopper()
  act(() => {
    userEvent.click(
      screen.getByRole('button', { name: 'Go to previous iteration' })
    )
  })
  queryCache.cancelQueries()

  expect(
    await screen.findByRole('heading', { name: 'Iteration 1' })
  ).toBeInTheDocument()
})

test('go to next iteration', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
    exercise: 'https://exercism.test/exercise',
  }
  const discussion = {
    id: 1,
    links: {
      posts: 'https://exercism.test/posts',
    },
  }
  const track = {
    title: 'Ruby',
  }
  const exercise = {
    title: 'Bob',
  }
  const student = {
    avatarUrl: 'https://exercism.test/avatar',
    links: {
      favorite: 'https://exercism.test/favorite',
    },
    reputation: 10,
  }
  const iterations = [
    {
      idx: 1,
      links: {
        files: 'https://exercism.test/iterations/1/files',
      },
      createdAt: new Date().toISOString(),
    },
    {
      idx: 2,
      links: {
        files: 'https://exercism.test/iterations/2/files',
      },
      createdAt: new Date().toISOString(),
    },
  ]

  render(
    <Session
      exercise={exercise}
      links={links}
      track={track}
      student={student}
      iterations={iterations}
      discussion={discussion}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Go to iteration 1' }))
  userEvent.click(screen.getByRole('button', { name: 'Go to next iteration' }))
  queryCache.cancelQueries()

  expect(
    await screen.findByRole('heading', { name: 'Iteration 2' })
  ).toBeInTheDocument()
})
