import React, { Component, type ErrorInfo, type ReactNode } from 'react'

type ErrorBoundaryProps = {
  children: ReactNode
  t: (key: string, options?: Record<string, any>) => string
}

type ErrorBoundaryState = {
  hasError: boolean
  error: Error | null
  errorInfo: ErrorInfo | null
}

class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = {
    hasError: false,
    error: null,
    errorInfo: null,
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
    const { t } = this.props

    if (this.state.hasError) {
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

    return this.props.children
  }
}

export default ErrorBoundary
