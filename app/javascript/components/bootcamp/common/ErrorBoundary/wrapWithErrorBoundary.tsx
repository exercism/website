import React from 'react'
import ErrorBoundary from './ErrorBoundary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

/**
 * higher order component that wraps a component with an ErrorBoundary
 */
export function wrapWithErrorBoundary<T>(Component: React.ComponentType<T>) {
  return function WrappedComponent(props: T & JSX.IntrinsicAttributes) {
    const { t } = useAppTranslation('components/bootcamp/common/ErrorBoundary')
    return (
      <ErrorBoundary t={t}>
        <Component {...props} />
      </ErrorBoundary>
    )
  }
}
