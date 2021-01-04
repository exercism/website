import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Accordion } from '../../../../app/javascript/components/common/Accordion'

test('expand accordion', () => {
  render(
    <Accordion index="accordion" open={false}>
      <Accordion.Header>Header</Accordion.Header>
      <Accordion.Panel>
        <p>Content</p>
      </Accordion.Panel>
    </Accordion>
  )

  userEvent.click(screen.getByRole('button', { name: 'Header' }))

  expect(screen.getByRole('button', { name: 'Header' })).toHaveAttribute(
    'aria-expanded',
    'true'
  )
  expect(screen.queryByText('Content')).toBeVisible()
})

test('collapse accordion', () => {
  render(
    <Accordion index="accordion" open={true}>
      <Accordion.Header>Header</Accordion.Header>
      <Accordion.Panel>
        <p>Content</p>
      </Accordion.Panel>
    </Accordion>
  )

  userEvent.click(screen.getByRole('button', { name: 'Header' }))

  expect(screen.getByRole('button', { name: 'Header' })).toHaveAttribute(
    'aria-expanded',
    'false'
  )
  expect(screen.queryByText('Content')).not.toBeVisible()
})
