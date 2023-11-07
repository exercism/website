import React, { useEffect, useState } from 'react'
import { ReputationIcon } from './reputation/ReputationIcon'
import { ReputationMenu } from './reputation/ReputationMenu'
import { ReputationChannel } from '../../channels/reputationChannel'
import { useDropdown, DropdownAttributes } from './useDropdown'
import { QueryKey, QueryStatus } from '@tanstack/react-query'
import { useErrorHandler, ErrorBoundary } from '../ErrorBoundary'
import { Loading } from '../common/Loading'
import { usePaginatedRequestQuery } from '../../hooks/request-query'

export type Links = {
  tokens: string
}

export type ReputationToken = {
  uuid: string
  internalUrl?: string
  externalUrl?: string
  iconUrl: string
  text: string
  createdAt: string
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
    unseenTotal: number
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
  cacheKey: QueryKey
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

export default function Reputation({
  defaultReputation,
  defaultIsSeen,
  endpoint,
}: {
  defaultReputation: number
  defaultIsSeen: boolean
  endpoint: string
}): JSX.Element {
  const [isStale, setIsStale] = useState(false)
  const [reputation, setReputation] = useState(defaultReputation)
  const [isSeen, setIsSeen] = useState(defaultIsSeen)
  const cacheKey = 'reputations'
  const {
    data: resolvedData,
    error,
    status,
    refetch,
  } = usePaginatedRequestQuery<APIResponse>([cacheKey], {
    endpoint: endpoint,
    query: { per_page: MAX_TOKENS },
    options: {},
  })
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown((resolvedData?.results.length || 0) + 1, undefined, {
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
    const connection = new ReputationChannel(() => setIsStale(true))

    return () => connection.disconnect()
  }, [])

  useEffect(() => {
    if (!resolvedData) {
      return
    }

    setReputation(resolvedData.meta.totalReputation)
  }, [resolvedData])

  useEffect(() => {
    if (!resolvedData) {
      return
    }

    setIsSeen(resolvedData.meta.unseenTotal === 0)
  }, [resolvedData])

  useEffect(() => {
    if (!listAttributes.hidden || !isStale) {
      return
    }

    refetch()
    setIsStale(false)
  }, [isStale, listAttributes.hidden, refetch])

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
            data={resolvedData}
            cacheKey={[cacheKey]}
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
