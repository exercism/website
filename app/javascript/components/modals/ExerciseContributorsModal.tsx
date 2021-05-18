import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { ModalProps, Modal } from './Modal'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { User } from '../types'

const DEFAULT_ERROR = new Error('Unable to load exercise contributors')

type APIResponse = {
  contributors: readonly User[]
}

export const ExerciseContributorsModal = ({
  endpoint,
  ...props
}: { endpoint: string } & ModalProps): JSX.Element => {
  const isMountedRef = useIsMounted()

  const { status, resolvedData, isFetching, error } = usePaginatedRequestQuery<
    APIResponse
  >(
    ['exercise-contributors', endpoint],
    { endpoint: endpoint, options: { enabled: props.open } },
    isMountedRef
  )

  return (
    <Modal {...props}>
      <h3>Exercise contributors</h3>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData
            ? resolvedData.contributors.map((contributor) => (
                <p key={contributor.handle}>{contributor.handle}</p>
              ))
            : null}
        </FetchingBoundary>
      </ResultsZone>
    </Modal>
  )
}
