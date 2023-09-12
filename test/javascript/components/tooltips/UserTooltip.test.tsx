import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { UserTooltip } from '../../../../app/javascript/components/tooltips'
import { TestQueryCache } from '../../support/TestQueryCache'
import { queryClient } from '../../setupTests'

test('correct information is displayed', async () => {
  const server = setupServer(
    rest.get(
      'https://exercism.test/tooltips/user_summary/1',
      (req, res, ctx) => {
        return res(
          ctx.json({
            html: `
            <div class='heading'>
              <div class="c-avatar" style="background-image:url("https://avatars2.githubusercontent.com/u/8953691?s=460&amp;u=593aaf70d7708aa3a98eb0b49a212a45263bc065&amp;v=4")"><img alt="Erik SchierBOOM&#39;s uploaded avatar" class="sr-only" src="https://avatars2.githubusercontent.com/u/8953691?s=460&amp;u=593aaf70d7708aa3a98eb0b49a212a45263bc065&amp;v=4" />
              </div>
              <div class='identifier'>
                <h4 class='name'>Erik ShireBOOM</h4>
                <div class='handle'>erikshireboom</div>
              </div>
              <div aria-label='0 reputation' class='c-reputation'>
                <svg role="img" class="c-icon "><title>Reputation</title><use xlink:href="#reputation" /></svg>
                0
              </div>
              </div>
              <div class='bio'>I am a developer with a passion for learning new languages. I love programming. I&#39;ve done all the languages. I like the good languages the best.</div>
              <div class='location'>
              <svg role="img" class="c-icon "><title>Located in</title><use xlink:href="#location" /></svg>
              Bree, Middle Earth.
            </div>`,
          })
        )
      }
    )
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <UserTooltip endpoint="https://exercism.test/tooltips/user_summary/1" />
    </TestQueryCache>
  )

  expect(await screen.findByText('Erik ShireBOOM')).toBeInTheDocument()
  expect(await screen.findByText('erikshireboom')).toBeInTheDocument()

  server.close()
})
