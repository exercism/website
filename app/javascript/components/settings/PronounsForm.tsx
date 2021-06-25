import React, { useState, useCallback } from 'react'
import { FormButton } from '../common'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'

type Links = {
  update: string
  info: string
}

type RequestBody = {
  user: {
    pronoun_parts: readonly string[]
  }
}

const DEFAULT_ERROR = new Error('Unable to update pronouns')

export const PronounsForm = ({
  handle,
  defaultPronounParts,
  links,
}: {
  handle: string
  defaultPronounParts: readonly string[]
  links: Links
}): JSX.Element => {
  const [pronounParts, setPronounParts] = useState<readonly string[]>(
    defaultPronounParts || ['', '', '']
  )

  const setPronounPart = useCallback(
    (part: string, index: number) => {
      const newPronounParts = [...pronounParts]
      newPronounParts[index] = part

      setPronounParts(newPronounParts)
    },
    [pronounParts]
  )

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user: { pronoun_parts: pronounParts } },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form onSubmit={handleSubmit}>
      <h2>How would you like to be addressed? (optional)</h2>
      <hr className="c-divider --small" />
      <div className="instructions">
        We recommend listing the pronouns you&apos;d like people to use when
        referring to you.{' '}
        <strong>
          In the example testimonial below, enter the pronouns you&apos;d like
          us to show to your mentors and students.
        </strong>{' '}
        You can leave this blank, in which case we will not suggest any
        pronouns.{' '}
        <a href={links.info} target="_blank" rel="noreferrer">
          Learn more about how we use pronouns.
        </a>
      </div>
      <div className="testimonial">
        <div className="text">
          {handle} was really great.{' '}
          <input
            type="text"
            value={pronounParts[0] || ''}
            placeholder="e.g. They"
            onChange={(e) => setPronounPart(e.target.value, 0)}
          />{' '}
          answered all my questions. I recommend{' '}
          <input
            type="text"
            value={pronounParts[1] || ''}
            placeholder="e.g. them"
            onChange={(e) => setPronounPart(e.target.value, 1)}
          />{' '}
          to others because
          <input
            type="text"
            value={pronounParts[2] || ''}
            placeholder="e.g. their"
            onChange={(e) => setPronounPart(e.target.value, 2)}
          />{' '}
          advice was very helpful.
        </div>
        <div className="commonly-used">
          <div className="info">Use a common option:</div>
          <button
            type="button"
            onClick={() => setPronounParts(['She', 'her', 'her'])}
          >
            she / her / her
          </button>
          <button
            type="button"
            onClick={() => setPronounParts(['He', 'him', 'his'])}
          >
            he / him / his
          </button>
          <button
            type="button"
            onClick={() => setPronounParts(['They', 'their', 'them'])}
          >
            they / their / them
          </button>
          <button
            type="button"
            onClick={() => setPronounParts([handle, handle, handle])}
          >
            Use handle
          </button>
          <button type="button" onClick={() => setPronounParts(['', '', ''])}>
            Leave blank
          </button>
        </div>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Save pronouns
        </FormButton>
        <FormMessage
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
          SuccessMessage={SuccessMessage}
        />
      </div>
    </form>
  )
}

const SuccessMessage = () => {
  return <span>Your pronouns have been saved.</span>
}
