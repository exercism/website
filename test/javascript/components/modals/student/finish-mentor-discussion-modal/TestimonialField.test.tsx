import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestimonialField } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/TestimonialField'

test('shows character count', async () => {
  render(
    <TestimonialField
      min={30}
      max={160}
      value="hello"
      id="testimonial"
      onChange={() => null}
    />
  )

  expect(screen.getByText('5 / 160')).toBeInTheDocument()
})

test('shows minimum characters', async () => {
  render(
    <TestimonialField
      min={30}
      max={160}
      value="hello"
      id="testimonial"
      onChange={() => null}
    />
  )

  expect(screen.getByText('30 minimum')).toBeInTheDocument()
})
