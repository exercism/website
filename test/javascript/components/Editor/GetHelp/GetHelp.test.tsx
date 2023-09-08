import React from 'react'
import { render, RenderResult, screen } from '@testing-library/react'
import { GetHelpPanel } from '@/components/editor/GetHelp'
import { MOCK_DATA } from './mockdata'

describe('GetHelp tests', () => {
  let renderedComponent: RenderResult

  beforeEach(() => {
    renderedComponent = render(
      <GetHelpPanel
        assignment={MOCK_DATA.ASSIGNMENT}
        helpHtml={MOCK_DATA.HELP}
      />
    )
  })

  test('Component snapshot test', () => {
    const { asFragment } = renderedComponent

    expect(asFragment()).toMatchSnapshot()
  })

  test('Component renders both hints and help', () => {
    const hint = screen.getByText(/Define the expected oven time in minutes/)
    const help = screen.getByText(/To get help if you're having trouble/)

    expect(hint).toBeInTheDocument()
    expect(help).toBeInTheDocument()
  })
})
