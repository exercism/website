import React from 'react'
import { QueryKey, useMutation, useQueryClient } from '@tanstack/react-query'
import { ReputationMenuItem } from './ReputationMenuItem'
import { GraphicalIcon } from '../../common'
import { ReputationToken, APIResponse } from '../Reputation'
import { DropdownAttributes } from '../useDropdown'
import { sendRequest } from '../../../utils/send-request'
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
  cacheKey: QueryKey
} & Pick<
  DropdownAttributes,
  'listAttributes' | 'itemAttributes'
>): JSX.Element => {
  const queryClient = useQueryClient()
  const { mutate: markAsSeen } = useMutation<
    ReputationToken,
    unknown,
    ReputationToken
  >(
    async (token) => {
      if (token.isSeen) {
        return Promise.resolve(token)
      }

      const { fetch } = sendRequest({
        endpoint: token.links.markAsSeen,
        method: 'PATCH',
        body: null,
      })

      return fetch.then((json) =>
        typecheck<ReputationToken>(json, 'reputation')
      )
    },
    {
      onSuccess: (token) => {
        const oldData = queryClient.getQueryData<APIResponse>(cacheKey)

        if (!oldData) {
          return
        }

        queryClient.setQueryData(cacheKey, {
          ...oldData,
          results: oldData.results.map((oldToken) => {
            return oldToken.uuid === token.uuid ? token : oldToken
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
            key={token.uuid}
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
