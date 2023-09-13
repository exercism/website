import React from 'react'
import { render, RenderResult, screen } from '@testing-library/react'
import { GetHelpPanel } from '@/components/editor/GetHelp'
import { MOCK_DATA } from './mockdata'

describe('GetHelpPanel tests', () => {
  let renderedComponent: RenderResult

  beforeEach(() => {
    renderedComponent = render(
      <GetHelpPanel
        assignment={MOCK_DATA.ASSIGNMENT}
        helpHtml={MOCK_DATA.HELP}
        links={{ discordRedirectPath: '', forumRedirectPath: '' }}
      />
    )
  })

  test('Component snapshot test', () => {
    const { asFragment } = renderedComponent

    expect(asFragment()).toMatchSnapshot()
  })

  test('Component renders hints, track help and community help', () => {
    const hint = screen.getByText(/Define the expected oven time in minutes/)
    const help = screen.getByText(/To get help if you're having trouble/)
    const communityHelp = screen.getByText('Community help')

    expect(hint).toBeInTheDocument()
    expect(help).toBeInTheDocument()
    expect(communityHelp).toBeInTheDocument()
  })
})
