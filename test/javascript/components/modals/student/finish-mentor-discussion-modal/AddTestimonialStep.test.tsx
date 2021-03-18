import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { AddTestimonialStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/AddTestimonialStep'

test('button says "Submit testimonial" if text box is populated', async () => {
  const links = {
    finish: '',
  }

  render(
    <AddTestimonialStep onSubmit={jest.fn()} onBack={jest.fn()} links={links} />
  )
  userEvent.type(screen.getByLabelText('Testimonial'), 'Test')

  expect(
    await screen.findByRole('button', { name: 'Submit testimonial' })
  ).toBeInTheDocument()
})

test('button says "Skip testimonial" if text box is not populated', async () => {
  const links = {
    finish: '',
  }

  render(
    <AddTestimonialStep onSubmit={jest.fn()} onBack={jest.fn()} links={links} />
  )

  expect(
    await screen.findByRole('button', { name: 'Skip testimonial' })
  ).toBeInTheDocument()
})

test('thumbs up icon shows when user starts typing', async () => {
  const links = {
    finish: '',
  }

  render(
    <AddTestimonialStep onSubmit={jest.fn()} onBack={jest.fn()} links={links} />
  )
  userEvent.type(screen.getByLabelText('Testimonial'), 'Test')

  expect(await screen.findByText('Thumbs up')).toBeInTheDocument()
})
