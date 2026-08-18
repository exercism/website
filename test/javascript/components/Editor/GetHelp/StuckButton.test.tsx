import React from 'react'
import { render, screen } from '@testing-library/react'
import { StuckButton } from '@/components/editor/GetHelp/StuckButton'

describe('Stuckbutton tests', () => {
  test('Component snapshot test', () => {
    const { asFragment } = render(
      <StuckButton insider={false} tab={'instructions'} setTab={() => null} />
    )
    expect(asFragment()).toMatchSnapshot()
  })

  test('Component shows the get help label', () => {
    render(
      <StuckButton insider={false} tab={'instructions'} setTab={() => null} />
    )

    const label = screen.getByText('Stuck? Get help')
    expect(label).toBeInTheDocument()
  })

  test('Component routes to the assistant tab', () => {
    const setTab = jest.fn()
    render(<StuckButton insider={false} tab={'instructions'} setTab={setTab} />)

    screen.getByRole('button').click()
    expect(setTab).toHaveBeenCalledWith('assistant')
  })

  test('Component is disabled if user is on the assistant tab', () => {
    render(<StuckButton insider={true} tab={'assistant'} setTab={() => null} />)

    const button = screen.getByRole('button')
    expect(button).toHaveAttribute('disabled')
  })
})
