import React from 'react'
import ErrorBoundary from './ErrorBoundary'

/**
 * higher order component that wraps a component with an ErrorBoundary
 */
export function wrapWithErrorBoundary<T>(Component: React.ComponentType<T>) {
  return function WrappedComponent(props: T & JSX.IntrinsicAttributes) {
    return (
      <ErrorBoundary>
        <Component {...props} />
      </ErrorBoundary>
    )
  }
}
