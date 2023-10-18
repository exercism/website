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

  test('Component shows correct button label if user is non-insider', () => {
    render(
      <StuckButton insider={false} tab={'instructions'} setTab={() => null} />
    )

    const label = screen.getByText('Stuck? Get help')
    expect(label).toBeInTheDocument()
  })
  test('Component shows correct button label if user is insider', () => {
    render(
      <StuckButton insider={true} tab={'instructions'} setTab={() => null} />
    )

    const label = screen.getByText('Stuck? Ask ChatGPT')
    expect(label).toBeInTheDocument()
  })

  test('Component is disabled if user is on the chat-gpt tab', () => {
    render(<StuckButton insider={true} tab={'chat-gpt'} setTab={() => null} />)

    const button = screen.getByRole('button')
    expect(button).toHaveAttribute('disabled')
  })
})
