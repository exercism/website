import React, { useCallback } from 'react'
import { redirectTo } from '../../utils/redirect-to'

export const LoadingOverlay = ({ url }: { url: string }): JSX.Element => {
  const handleClick = useCallback(() => {
    redirectTo(url)
  }, [url])

  return <button onClick={handleClick}>Redirect</button>
}
