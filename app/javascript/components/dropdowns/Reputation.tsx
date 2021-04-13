import React, { useEffect, useState } from 'react'
import { ReputationIcon } from './reputation/ReputationIcon'
import { ReputationMenu } from './reputation/ReputationMenu'
import { ReputationChannel } from '../../channels/reputationChannel'
import { useDropdown, DropdownAttributes } from './useDropdown'
import { useIsMounted } from 'use-is-mounted'
import { QueryStatus } from 'react-query'
import { useErrorHandler, ErrorBoundary } from '../ErrorBoundary'
import { Loading } from '../common/Loading'
import { useRequestQuery } from '../../hooks/request-query'

export type Links = {
  tokens: string
}

export type ReputationToken = {
  id: string
  internalUrl?: string
  externalUrl?: string
  iconUrl: string
  text: string
  awardedAt: string
  value: string
  isSeen: boolean
  links: {
    markAsSeen: string
  }
}

export type APIResponse = {
  results: ReputationToken[]
  meta: {
    links: {
      tokens: string
    }
    totalReputation: number
  }
}

const DEFAULT_ERROR = new Error('Unable to retrieve reputation tokens')

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return <p>{error.message}</p>
}

const DropdownContent = ({
  data,
  cacheKey,
  status,
  error,
  listAttributes,
  itemAttributes,
}: {
  data: APIResponse | undefined
  cacheKey: string
  status: QueryStatus
  error: unknown
} & Pick<DropdownAttributes, 'listAttributes' | 'itemAttributes'>) => {
  if (data) {
    return (
      <ReputationMenu
        tokens={data.results}
        links={data.meta.links}
        listAttributes={listAttributes}
        itemAttributes={itemAttributes}
        cacheKey={cacheKey}
      />
    )
  } else {
    const { id, hidden } = listAttributes

    return (
      <div id={id} hidden={hidden}>
        {status === 'loading' ? <Loading /> : null}
        <ErrorBoundary FallbackComponent={ErrorFallback}>
          <ErrorMessage error={error} />
        </ErrorBoundary>
      </div>
    )
  }
}

const MAX_TOKENS = 5

export const Reputation = ({
  defaultReputation,
  defaultIsSeen,
  endpoint,
}: {
  defaultReputation: number
  defaultIsSeen: boolean
  endpoint: string
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [reputation, setReputation] = useState(defaultReputation)
  const [isSeen, setIsSeen] = useState(defaultIsSeen)
  const cacheKey = 'reputations'
  const { data, error, status, refetch } = useRequestQuery<APIResponse>(
    cacheKey,
    { endpoint: endpoint, query: { per: MAX_TOKENS }, options: {} },
    isMountedRef
  )
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(0, undefined, {
    placement: 'bottom-start',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  useEffect(() => {
    const connection = new ReputationChannel(refetch)

    return () => connection.disconnect()
  }, [refetch])

  useEffect(() => {
    if (!data) {
      return
    }

    setReputation(data.meta.totalReputation)
  }, [data])

  useEffect(() => {
    if (!data) {
      return
    }

    setIsSeen(data.results.every((token) => token.isSeen))
  }, [data])

  return (
    <React.Fragment>
      <ReputationIcon
        reputation={reputation}
        isSeen={isSeen}
        {...buttonAttributes}
      />
      {open ? (
        <div className="c-reputation-dropdown" {...panelAttributes}>
          <DropdownContent
            data={data}
            cacheKey={cacheKey}
            status={status}
            error={error}
            itemAttributes={itemAttributes}
            listAttributes={listAttributes}
          />
        </div>
      ) : null}
    </React.Fragment>
  )
}
