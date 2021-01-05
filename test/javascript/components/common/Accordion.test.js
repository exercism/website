import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Accordion } from '../../../../app/javascript/components/common/Accordion'

test('closed accordion', () => {
  render(
    <Accordion id="accordion" isOpen={false}>
      <Accordion.Header>Header</Accordion.Header>
      <Accordion.Panel>
        <p>Content</p>
      </Accordion.Panel>
    </Accordion>
  )

  expect(screen.getByRole('button', { name: 'Header' })).toHaveAttribute(
    'aria-expanded',
    'false'
  )
  expect(screen.queryByText('Content')).not.toBeVisible()
})

test('open accordion', () => {
  render(
    <Accordion id="accordion" isOpen={true}>
      <Accordion.Header>Header</Accordion.Header>
      <Accordion.Panel>
        <p>Content</p>
      </Accordion.Panel>
    </Accordion>
  )

  expect(screen.getByRole('button', { name: 'Header' })).toHaveAttribute(
    'aria-expanded',
    'true'
  )
  expect(screen.queryByText('Content')).toBeVisible()
})
