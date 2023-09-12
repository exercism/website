import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostList } from '../../../../../app/javascript/components/mentoring/discussion/DiscussionPostList'
import { stubIntersectionObserver } from '../../../support/intersection-observer-helpers'
import { createIteration } from '../../../factories/IterationFactory'
import { createDiscussionPost } from '../../../factories/DiscussionPostFactory'

stubIntersectionObserver()

test('displays all posts', async () => {
  const posts = [createDiscussionPost({ contentHtml: '<p>Hello</p>' })]
  const iterations = [createIteration({ idx: 1, posts: posts })]

  render(
    <DiscussionPostList
      iterations={iterations}
      discussionUuid="uuid"
      userHandle="user"
      userIsStudent={false}
      onIterationScroll={jest.fn()}
      status="success"
    />
  )

  expect(screen.getByText('Hello')).toBeInTheDocument()
})

test('shows first iteration with posts', async () => {
  stubScroll()
  const posts = [createDiscussionPost({})]
  const iterations = [
    createIteration({ idx: 1 }),
    createIteration({ idx: 2, posts: posts }),
  ]

  render(
    <DiscussionPostList
      iterations={iterations}
      discussionUuid="uuid"
      userHandle="user"
      onIterationScroll={jest.fn()}
      userIsStudent={true}
      status="success"
    />
  )

  expect(screen.getByText('Iteration 2')).toBeInTheDocument()
  expect(screen.queryByText('Iteration 1')).not.toBeInTheDocument()
})

test('shows latest iteration if there are no posts', async () => {
  const iterations = [createIteration({ idx: 1 }), createIteration({ idx: 2 })]

  render(
    <DiscussionPostList
      iterations={iterations}
      discussionUuid="uuid"
      userHandle="user"
      onIterationScroll={jest.fn()}
      userIsStudent={true}
      status="success"
    />
  )

  expect(screen.queryByText('Iteration 1')).not.toBeInTheDocument()
  expect(screen.getByText('Iteration 2')).toBeInTheDocument()
})

test.skip('allows editing one post at a time only', async () => {
  // probably extract to another component
})

function stubScroll() {
  Element.prototype.scrollIntoView = jest.fn()
}
