import React from 'react'

const MAX_RETRIES = 3
const RETRY_DELAY_MS = 1000

/**
 * Drop-in replacement for React.lazy that retries the dynamic import
 * on transient failures (network blips, CDN hiccups, etc.).
 */
export function lazy<T extends React.ComponentType<any>>(
  factory: () => Promise<{ default: T }>
): React.LazyExoticComponent<T> {
  return React.lazy(() => retryImport(factory))
}

function retryImport<T extends React.ComponentType<any>>(
  factory: () => Promise<{ default: T }>,
  retriesLeft = MAX_RETRIES
): Promise<{ default: T }> {
  return factory().catch((error) => {
    if (retriesLeft <= 0) throw error

    return new Promise<{ default: T }>((resolve) =>
      setTimeout(
        () => resolve(retryImport(factory, retriesLeft - 1)),
        RETRY_DELAY_MS
      )
    )
  })
}
