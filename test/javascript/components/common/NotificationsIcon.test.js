import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { NotificationsIcon } from '../../../../app/javascript/components/common/NotificationsIcon'

test('assigns the correct CSS classes based on notification count', async () => {
  let component

  component = render(<NotificationsIcon count={0} />)
  expect(component.container.firstChild).toHaveClass('--none')

  component = render(<NotificationsIcon count={1} />)
  expect(component.container.firstChild).toHaveClass('--single-digit')

  component = render(<NotificationsIcon count={9} />)
  expect(component.container.firstChild).toHaveClass('--single-digit')

  component = render(<NotificationsIcon count={10} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')

  component = render(<NotificationsIcon count={99} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')

  component = render(<NotificationsIcon count={100} />)
  expect(component.container.firstChild).toHaveClass('--triple-digit')
})
