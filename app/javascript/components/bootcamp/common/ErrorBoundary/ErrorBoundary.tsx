import React from 'react'
import { Component, type ErrorInfo, type ReactNode } from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

class ErrorBoundary extends Component<
  { children: ReactNode },
  { hasError: boolean; error: Error | null; errorInfo: ErrorInfo | null }
> {
  state = {
    hasError: false,
    error: null as Error | null,
    errorInfo: null as ErrorInfo | null,
  }

  static getDerivedStateFromError() {
    return { hasError: true }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Caught error:', error)
    console.error('Error details:', errorInfo)
    this.setState({ error, errorInfo })
  }

  handleReload = () => {
    this.setState({ hasError: false, error: null, errorInfo: null })
  }

  render() {
    const { t } = useAppTranslation('components/bootcamp/common/ErrorBoundary')

    if (this.state.hasError) {
      // generic fallback UI
      return (
        <div className="p-8 flex flex-col gap-8">
          <h1 className="text-lg font-semibold">
            {t('errorBoundary.somethingWentWrong')}
          </h1>
          {this.state.error && (
            <p className="text-md text-red-700 font-semibold">
              {t('errorBoundary.error', { message: this.state.error.message })}
            </p>
          )}
          {/* probably hide this in prod */}
          {this.state.errorInfo && (
            <details
              className="select-none cursor-pointer"
              style={{ whiteSpace: 'pre-wrap' }}
            >
              {this.state.errorInfo.componentStack}
            </details>
          )}
          <div className="flex gap-8 [&_button]:p-4 [&_button]:rounded-md">
            <button className="btn-standard" onClick={this.handleReload}>
              {t('errorBoundary.reloadComponent')}
            </button>
            <button
              className="btn-standard"
              onClick={() => window.location.reload()}
            >
              {t('errorBoundary.reloadApp')}
            </button>
          </div>
        </div>
      )
    }

    // if no error -> render children
    return this.props.children
  }
}

export default ErrorBoundary
