import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Widget } from '../../../../app/javascript/components/notifications/Widget'

test('assigns the correct CSS classes based on notification count', async () => {
  let component

  component = render(<Widget count={0} />)
  expect(component.container.firstChild).toHaveClass('--none')

  component = render(<Widget count={1} />)
  expect(component.container.firstChild).toHaveClass('--digital')

  component = render(<Widget count={9} />)
  expect(component.container.firstChild).toHaveClass('--digital')

  component = render(<Widget count={10} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')

  component = render(<Widget count={99} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')

  component = render(<Widget count={100} />)
  expect(component.container.firstChild).toHaveClass('--triple-digit')
})
