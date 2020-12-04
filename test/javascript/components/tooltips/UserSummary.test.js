import React from 'react'
import { render, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { UserSummaryTooltip } from '../../../../app/javascript/components/tooltips'

test('correct information is displayed', async () => {
  const server = setupServer(
    rest.get(
      'https://exercism.test/tooltips/user_summary/1',
      (req, res, ctx) => {
        return res(
          ctx.text(
            `<div class='heading'>
<div class="c-rounded-bg-img" style="background-image:url(https://avatars2.githubusercontent.com/u/8953691?s=460&amp;u=593aaf70d7708aa3a98eb0b49a212a45263bc065&amp;v=4)"><img alt="Erik SchierBOOM&#39;s uploaded avatar" class="tw-sr-only" src="https://avatars2.githubusercontent.com/u/8953691?s=460&amp;u=593aaf70d7708aa3a98eb0b49a212a45263bc065&amp;v=4" /></div>
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
</div>`
          )
        )
      }
    )
  )
  server.listen()

  const { getByText } = render(
    <UserSummaryTooltip
      contentEndpoint="https://exercism.test/tooltips/user_summary/1"
      hoverRequestToShow={true}
      focusRequestToShow={true}
      referenceElement={null}
      referenceUserHandle="erikshireboom"
    />
  )

  await waitFor(() => expect(getByText('Erik ShireBOOM')).toBeInTheDocument())
  await waitFor(() => expect(getByText('erikshireboom')).toBeInTheDocument())

  server.close()
})
