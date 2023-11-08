import React from 'react'

import userEvent from '@testing-library/user-event'
import {
  screen,
  act,
  waitForElementToBeRemoved,
  waitFor,
} from '@testing-library/react'
import { render } from '../../test-utils'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { default as Session } from '@/components/mentoring/Session'
import { stubRange } from '../../support/code-mirror-helpers'
import { stubIntersectionObserver } from '../../support/intersection-observer-helpers'
import { awaitPopper } from '../../support/await-popper'
import { expectConsoleError } from '../../support/silence-console'

stubRange()
stubIntersectionObserver()

const guidance = {
  exercise: '<p>These are notes for lasagna.</p>\n',
  links: {
    improveExerciseGuidance: 'https://exercism.org',
    improveTrackGuidance: 'https://exercism.org',
    improveRepresenterGuidance: 'https://exercism.org',
  },
}

test('highlights currently selected iteration', async () => {
  const scratchpad = {
    links: {
      self: 'http://exercism.test/scratchpad',
    },
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
        scratchpad={scratchpad}
        track={track}
        student={student}
        iterations={iterations}
        discussion={discussion}
        exemplarFiles={[]}
        links={{}}
        guidance={guidance}
        request={{ isLocked: true }}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Go to iteration 1' }))

    expect(
      await screen.findByRole('button', { name: 'Go to iteration 1' })
    ).toHaveAttribute('aria-current', 'true')

    await awaitPopper()
  })
})

test('shows back button', async () => {
  const links = {
    mentorDashboard: 'https://exercism.test/mentor/dashboard',
    exercise: 'https://exercism.test/exercise',
  }
  const scratchpad = {
    links: {
      self: 'https://exercism.test/scratchpad',
    },
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
      scratchpad={scratchpad}
      exemplarFiles={[]}
      guidance={guidance}
      request={{ isLocked: true }}
    />
  )

  expect(
    await screen.findByRole('link', {
      name: 'Close discussion and return to mentoring dashboard',
    })
  ).toHaveAttribute('href', 'https://exercism.test/mentor/dashboard')
})

test('hides latest label if on old iteration', async () => {
  const links = {
    exercise: 'https://exercism.test/exercise',
  }
  const scratchpad = {
    links: {
      self: 'https://exercism.test/scratchpad',
    },
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
      scratchpad={scratchpad}
      exemplarFiles={[]}
      guidance={guidance}
      request={{ isLocked: true }}
    />
  )
  await awaitPopper()
  act(() => {
    userEvent.click(screen.getByRole('button', { name: 'Go to iteration 1' }))
  })

  expect(
    await screen.findByRole('button', { name: 'Go to iteration 1' })
  ).toBeDisabled()
  expect(screen.queryByText('latest')).not.toBeInTheDocument()
})

test('switches to posts tab when comment success', async () => {
  const links = {
    exercise: 'https://exercism.test/exercise',
  }
  const scratchpad = {
    links: {
      self: 'https://exercism.test/scratchpad',
    },
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
      return res(ctx.delay(10), ctx.status(200), ctx.json({ item: {} }))
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
      scratchpad={scratchpad}
      exemplarFiles={[]}
      guidance={guidance}
      request={{ isLocked: true }}
    />
  )

  userEvent.click(screen.getByRole('tab', { name: 'Scratchpad' }))
  userEvent.click(screen.getByTestId('markdown-editor'))
  // TODO: Replace this with findByUndefined, don't use DOM selectors in test
  await waitFor(() =>
    expect(document.querySelector('.comment-section .CodeMirror')).toBeDefined()
  )
  act(() =>
    document
      .querySelector('.comment-section .CodeMirror')
      .CodeMirror.setValue('#Hello')
  )
  const button = screen.getByRole('button', { name: 'Send' })
  userEvent.click(button)

  await waitForElementToBeRemoved(button)

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
    exercise: 'https://exercism.test/exercise',
  }
  const scratchpad = {
    links: {
      self: 'https://exercism.test/scratchpad',
    },
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
      scratchpad={scratchpad}
      exemplarFiles={[]}
      guidance={guidance}
      request={{ isLocked: true }}
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

test('go to previous iteration', async () => {
  const links = {
    exercise: 'https://exercism.test/exercise',
  }
  const scratchpad = {
    links: {
      self: 'https://exercism.test/scratchpad',
    },
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
        scratchpad={scratchpad}
        exemplarFiles={[]}
        guidance={guidance}
        request={{ isLocked: true }}
      />
    )
  })
  await awaitPopper()
  act(() => {
    userEvent.click(
      screen.getByRole('button', { name: 'Go to previous iteration' })
    )
  })

  expect(
    await screen.findByRole('heading', { name: 'Iteration 1' })
  ).toBeInTheDocument()
})

test('go to next iteration', async () => {
  const links = {
    exercise: 'https://exercism.test/exercise',
  }
  const scratchpad = {
    links: {
      self: 'https://exercism.test/scratchpad',
    },
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
      scratchpad={scratchpad}
      exemplarFiles={[]}
      guidance={guidance}
      request={{ isLocked: true }}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Go to iteration 1' }))
  userEvent.click(screen.getByRole('button', { name: 'Go to next iteration' }))

  expect(
    await screen.findByRole('heading', { name: 'Iteration 2' })
  ).toBeInTheDocument()
})
