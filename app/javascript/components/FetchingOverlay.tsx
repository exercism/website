import React from 'react'

export const FetchingOverlay = ({
  isFetching,
  children,
}: React.PropsWithChildren<{ isFetching: boolean }>): JSX.Element => {
  return isFetching ? (
    <div className="fetching-overlay">
      {children}
      <div className="fetching-overlay-overlay" />
    </div>
  ) : (
    <React.Fragment>{children}</React.Fragment>
  )
}
