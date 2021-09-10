import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ReputationMenuItem } from '../../../../../app/javascript/components/dropdowns/reputation/ReputationMenuItem'

test('should hide icon when link is empty', async () => {
  const props = {
    uuid: 'uuid',
    iconUrl: 'https://exercism.test/icon',
    text: 'You contributed',
    earnedOn: new Date().toISOString(),
    value: '10',
    isSeen: false,
    links: {
      markAsSeen: 'https://exercism.test/tokens/uuid/mark_as_seen',
    },
  }
  render(<ReputationMenuItem {...props} />)

  expect(screen.queryByAltText('Open link')).not.toBeInTheDocument()
})
