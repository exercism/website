import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { RevealedTestimonial } from '../../../../../app/javascript/components/mentoring/testimonials-list/RevealedTestimonial'
import { createTestimonial } from '../../../factories/TestimonialFactory'
import userEvent from '@testing-library/user-event'

test('clicking cancel closes the delete modal', async () => {
  render(
    <RevealedTestimonial
      testimonial={createTestimonial()}
      cacheKey={['CACHE_KEY']}
      isRevealed
      platforms={[]}
    />
  )

  userEvent.click(screen.getByAltText('Options'))
  userEvent.click(
    await screen.findByRole('button', { name: 'Delete testimonial' })
  )
  userEvent.click(await screen.findByRole('button', { name: 'Cancel' }))

  expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
})
