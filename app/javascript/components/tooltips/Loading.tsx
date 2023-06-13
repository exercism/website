import React, { useState, useEffect } from 'react'
import { Icon } from '../common'

export const Loading = ({ alt }: { alt: string }): JSX.Element | null => {
  const [isShowing, setIsShowing] = useState(false)

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsShowing(true)
    }, 50)

    return () => clearTimeout(timer)
  }, [])

  return isShowing ? (
    <Icon icon="spinner" alt={alt} className="c-tooltip-spinner" />
  ) : null
}
