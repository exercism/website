import React from 'react'
import {
  render,
  screen,
  waitFor,
  act,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostList } from '../../../../../app/javascript/components/mentoring/discussion/DiscussionPostList'
import { TestQueryCache } from '../../../support/TestQueryCache'
import { stubIntersectionObserver } from '../../../support/intersection-observer-helpers'
import { queryCache } from 'react-query'
import { createIteration } from '../../../factories/IterationFactory'
import { createDiscussionPost } from '../../../factories/DiscussionPostFactory'
import userEvent from '@testing-library/user-event'

stubIntersectionObserver()

test('displays all posts', async () => {
  stubScroll()
  const posts = [createDiscussionPost({ contentHtml: '<p>Hello</p>' })]
  const server = setupServer(
    rest.get('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.json({ posts: posts }))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <DiscussionPostList
        iterations={[createIteration({ idx: 1 })]}
        endpoint="https://exercism.test/posts"
        discussionUuid="uuid"
        userHandle="user"
        userIsStudent={false}
        onIterationScroll={jest.fn()}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('Hello')).toBeInTheDocument()

  queryCache.cancelQueries()
  server.close()
})

test('shows first iteration with posts', async () => {
  stubScroll()
  const iterations = [createIteration({ idx: 1 }), createIteration({ idx: 2 })]
  const posts = [createDiscussionPost({ iterationIdx: 2 })]

  const server = setupServer(
    rest.get('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.json({ posts: posts }))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <DiscussionPostList
        iterations={iterations}
        discussionUuid="uuid"
        userHandle="user"
        endpoint="https://exercism.test/posts"
        onIterationScroll={jest.fn()}
        userIsStudent={true}
      />
    </TestQueryCache>
  )

  await waitForElementToBeRemoved(() =>
    screen.getByRole('status', {
      name: 'Discussion post list loading indicator',
    })
  )

  expect(await screen.findByText('Iteration 2')).toBeInTheDocument()
  await waitFor(() => {
    expect(screen.queryByText('Iteration 1')).not.toBeInTheDocument()
  })

  queryCache.cancelQueries()
  server.close()
})

test('shows latest iteration if there are no posts', async () => {
  stubScroll()
  const iterations = [createIteration({ idx: 1 }), createIteration({ idx: 2 })]
  const server = setupServer(
    rest.get('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.json({ posts: [] }))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <DiscussionPostList
        iterations={iterations}
        discussionUuid="uuid"
        userHandle="user"
        endpoint="https://exercism.test/posts"
        onIterationScroll={jest.fn()}
        userIsStudent={true}
      />
    </TestQueryCache>
  )

  await waitFor(() => {
    expect(screen.queryByText('Iteration 1')).not.toBeInTheDocument()
  })
  expect(await screen.findByText('Iteration 2')).toBeInTheDocument()

  server.close()
})

test.skip('allows editing one post at a time only', async () => {
  // probably extract to another component
})

function stubScroll() {
  Element.prototype.scrollIntoView = jest.fn()
}
