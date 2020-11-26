import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { NotificationIcon } from '../../../../app/javascript/components/common/NotificationIcon'

test('assigns the correct CSS classes based on notification count', async () => {
  let component

  component = render(<NotificationIcon count={0} />)
  expect(component.container.firstChild).toHaveClass('--none')

  component = render(<NotificationIcon count={1} />)
  expect(component.container.firstChild).toHaveClass('--digital')

  component = render(<NotificationIcon count={9} />)
  expect(component.container.firstChild).toHaveClass('--digital')

  component = render(<NotificationIcon count={10} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')

  component = render(<NotificationIcon count={99} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')

  component = render(<NotificationIcon count={100} />)
  expect(component.container.firstChild).toHaveClass('--triple-digit')
})
