import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { NotificationsIcon } from '../../../../../app/javascript/components/dropdowns/notifications/NotificationsIcon'

test('assigns the --none variant when count is 0', async () => {
  const { container } = render(<NotificationsIcon count={0} />)

  expect(container.firstChild).toHaveClass('--none')
})

test('assigns the --single-digit variant when count is from 1 to 9', async () => {
  let component

  component = render(<NotificationsIcon count={1} />)
  expect(component.container.firstChild).toHaveClass('--single-digit')

  component = render(<NotificationsIcon count={7} />)
  expect(component.container.firstChild).toHaveClass('--single-digit')

  component = render(<NotificationsIcon count={9} />)
  expect(component.container.firstChild).toHaveClass('--single-digit')
})

test('assigns the --double-digit variant when count is from 10 to 99', async () => {
  let component

  component = render(<NotificationsIcon count={10} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')

  component = render(<NotificationsIcon count={50} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')

  component = render(<NotificationsIcon count={99} />)
  expect(component.container.firstChild).toHaveClass('--double-digit')
})

test('assigns the --triple-digit variant when count is from 100+', async () => {
  let component

  component = render(<NotificationsIcon count={100} />)
  expect(component.container.firstChild).toHaveClass('--triple-digit')

  component = render(<NotificationsIcon count={200} />)
  expect(component.container.firstChild).toHaveClass('--triple-digit')
})
