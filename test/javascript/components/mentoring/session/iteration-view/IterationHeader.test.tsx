import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import {
  IterationHeader,
  Props,
} from '../../../../../../app/javascript/components/mentoring/session/iteration-view/IterationHeader'
import { build, perBuild } from '@jackfranklin/test-data-bot'
import { createIteration } from '../../../../factories/IterationFactory'
import { createFile } from '../../../../factories/FileFactory'

const buildProps = build<Props>({
  fields: {
    iteration: createIteration({}),
    isOutOfDate: perBuild(() => false),
    downloadCommand: 'exercism download',
    files: [createFile({})],
  },
})

test('renders out of date notice', async () => {
  render(<IterationHeader {...buildProps()} isOutOfDate />)

  expect(screen.getByText('Outdated')).toBeInTheDocument()
})

test('does not render out of date notice', async () => {
  render(<IterationHeader {...buildProps()} isOutOfDate={false} />)

  expect(screen.queryByText('Outdated')).not.toBeInTheDocument()
})
