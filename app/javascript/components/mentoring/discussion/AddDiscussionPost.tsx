import React, { useCallback, useState } from 'react'
import { DiscussionPostForm } from './DiscussionPostForm'

export const AddDiscussionPost = ({
  isFinished,
  endpoint,
  contextId,
  onSuccess = () => {},
}: {
  isFinished: boolean
  endpoint: string
  contextId: string
  onSuccess?: () => void
}): JSX.Element => {
  const [state, setState] = useState({
    expanded: false,
    value: localStorage.getItem(`smde_${contextId}`) || '',
  })

  const handleSuccess = useCallback(() => {
    setState({ value: '', expanded: false })

    onSuccess()
  }, [onSuccess])

  const handleClick = useCallback(() => {
    if (state.expanded) {
      return
    }

    setState({ ...state, expanded: true })
  }, [state])

  const handleContinue = useCallback(() => {
    setState({ ...state, expanded: true })
  }, [state])

  const handleCancel = useCallback(() => {
    setState({ ...state, expanded: false })
  }, [state])

  const handleChange = useCallback(
    (value: string) => {
      setState({ ...state, value: value })
    },
    [state]
  )

  if (isFinished && !state.expanded) {
    return (
      <button
        onClick={handleContinue}
        className="continuation-btn"
        type="button"
      >
        <strong>This discussion has ended.</strong> Have more to say? You can{' '}
        <em>still post</em>.
      </button>
    )
  }

  return (
    <>
      <DiscussionPostForm
        onSuccess={handleSuccess}
        onClick={handleClick}
        onCancel={handleCancel}
        onChange={handleChange}
        endpoint={endpoint}
        method="POST"
        contextId={contextId}
        value={state.value}
        expanded={state.expanded}
      />

      <div className="note">
        Check out our {/* TODO */}
        <a href="#">mentoring docs</a> and be the best mentor you can be.
      </div>
    </>
  )
}
