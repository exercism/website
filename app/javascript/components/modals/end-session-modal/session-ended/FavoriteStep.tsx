import React from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { Discussion, Relationship } from '../../EndSessionModal'
import { typecheck } from '../../../../utils/typecheck'

export const FavoriteStep = ({
  discussion,
  onFavorite,
  onSkip,
}: {
  discussion: Discussion
  onFavorite: (relationship: Relationship) => void
  onSkip: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [handleFavorite] = useMutation(
    () => {
      return sendRequest({
        endpoint: discussion.relationship.links.favorite,
        method: 'POST',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<Relationship>(json, 'relationship')
      })
    },
    {
      onSuccess: (relationship) => {
        if (!relationship) {
          return
        }

        onFavorite(relationship)
      },
    }
  )

  return (
    <div>
      <p>Add {discussion.student.handle} to your favorites?</p>
      <button type="button" onClick={() => handleFavorite()}>
        Add to favorites
      </button>
      <button type="button" onClick={() => onSkip()}>
        Skip
      </button>
    </div>
  )
}
