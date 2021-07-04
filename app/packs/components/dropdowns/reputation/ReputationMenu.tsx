import React from 'react'
import { ReputationMenuItem } from './ReputationMenuItem'
import { GraphicalIcon } from '../../common'
import { ReputationToken, APIResponse } from '../Reputation'
import { DropdownAttributes } from '../useDropdown'
import { useMutation, queryCache } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../utils/typecheck'

export const ReputationMenu = ({
  tokens,
  listAttributes,
  cacheKey,
  itemAttributes,
  links,
}: {
  tokens: ReputationToken[]
  links: { tokens: string }
  cacheKey: string
} & Pick<
  DropdownAttributes,
  'listAttributes' | 'itemAttributes'
>): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [markAsSeen] = useMutation<
    ReputationToken | undefined,
    unknown,
    ReputationToken
  >(
    (token) => {
      if (token.isSeen) {
        return Promise.resolve(undefined)
      }

      return sendRequest({
        endpoint: token.links.markAsSeen,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<ReputationToken>(json, 'reputation')
      })
    },
    {
      onSuccess: (token) => {
        if (!token) {
          return
        }

        const oldData = queryCache.getQueryData<APIResponse>(cacheKey)

        if (!oldData) {
          return
        }

        queryCache.setQueryData(cacheKey, {
          ...oldData,
          results: oldData.results.map((oldToken) => {
            return oldToken.id === token.id ? token : oldToken
          }),
        })
      },
    }
  )

  return (
    <ul {...listAttributes}>
      {tokens.map((token, i) => {
        return (
          <li
            key={token.id}
            {...itemAttributes(i)}
            onMouseEnter={() => {
              markAsSeen(token)
            }}
            onFocus={() => {
              markAsSeen(token)
            }}
          >
            <ReputationMenuItem {...token} />
          </li>
        )
      })}
      <li {...itemAttributes(tokens.length)}>
        <a href={links.tokens} className="c-prominent-link">
          See how you earned all your reputation
          <GraphicalIcon icon="arrow-right" />
        </a>
      </li>
    </ul>
  )
}
