import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import ImpactMap from '@/components/impact/map'
import { Metric } from '@/components/types'

test('renders an open issue metric that has no user', () => {
  const metric = {
    id: 1,
    type: 'open_issue_metric',
    coordinates: [35.6897, 139.6895],
    countryCode: 'jp',
    countryName: 'Japan',
  } as unknown as Metric

  const { container } = render(<ImpactMap initialMetrics={[metric]} />)

  const point = container.querySelector('.metric-open_issue_metric')
  expect(point).toBeInTheDocument()
  expect(point).toBeEmptyDOMElement()
})
