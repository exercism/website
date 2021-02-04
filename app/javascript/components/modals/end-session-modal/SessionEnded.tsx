import React, { useState } from 'react'
import { Discussion } from '../EndSessionModal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'

type ModalStep = 'mentorAgain' | 'favorite' | 'favorited'

const FavoritedStep = ({
  discussion,
}: {
  discussion: Discussion
}): JSX.Element => {
  return <p>{discussion.student.handle} is one of your favorites.</p>
}

const FavoriteStep = ({
  discussion,
  onFavorite,
}: {
  discussion: Discussion
  onFavorite: () => void
}) => {
  const isMountedRef = useIsMounted()
  const [handleFavorite] = useMutation(
    () => {
      return sendRequest({
        endpoint: discussion.student.links.favorite,
        method: 'POST',
        body: null,
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: () => {
        onFavorite()
      },
    }
  )

  return (
    <div>
      <p>Add {discussion.student.handle} to your favorites?</p>
      <button type="button" onClick={() => handleFavorite()}>
        Add to favorites
      </button>
    </div>
  )
}

const MentorAgainStep = ({
  discussion,
  onYes,
}: {
  discussion: Discussion
  onYes: () => void
}) => {
  const isMountedRef = useIsMounted()
  const [handleYes] = useMutation(
    () => {
      return sendRequest({
        endpoint: discussion.student.links.mentorAgain,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: () => {
        onYes()
      },
    }
  )

  return (
    <div>
      <p>Want to mentor {discussion.student.handle} again?</p>
      <button onClick={() => handleYes()}>Yes</button>
    </div>
  )
}

export const SessionEnded = ({
  discussion,
}: {
  discussion: Discussion
}): JSX.Element => {
  const [step, setStep] = useState<ModalStep>('mentorAgain')

  return (
    <div>
      <h1>
        You&apos;ve ended your discussion with {discussion.student.handle}.
      </h1>
      {step === 'mentorAgain' ? (
        <MentorAgainStep
          discussion={discussion}
          onYes={() => {
            setStep('favorite')
          }}
        />
      ) : null}
      {step === 'favorite' ? (
        <FavoriteStep
          discussion={discussion}
          onFavorite={() => {
            setStep('favorited')
          }}
        />
      ) : null}
      {step === 'favorited' ? <FavoritedStep discussion={discussion} /> : null}
    </div>
  )
}
