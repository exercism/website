import React, { useEffect, useState } from 'react'
import { IterationStatus } from '../types'
import { GraphicalIcon } from '.'

function Content({ status }: { status: string }) {
  switch (status) {
    case 'processing':
      return (
        <>
          <GraphicalIcon icon="spinner" className="animate-spin-slow" />
          <div className="--status">Processing</div>
        </>
      )
    case 'failed':
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Failed</div>
        </>
      )
    default:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Passed</div>
        </>
      )
  }
}

function transformStatus(iterationStatus: IterationStatus): string {
  switch (iterationStatus) {
    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return 'processing'
    case IterationStatus.TESTS_FAILED:
      return 'failed'
    default:
      return 'passed'
  }
}

export function ProcessingStatusSummary({
  iterationStatus,
  iterationUuid,
}: {
  iterationStatus: IterationStatus
  iterationUuid?: string
}): JSX.Element {
  const [currentStatus, setCurrentStatus] = useState<IterationStatus>(iterationStatus)
  
  // Auto-refresh the status for iterations that are in processing state
  useEffect(() => {
    // Update the local state when the prop changes
    setCurrentStatus(iterationStatus)
    
    // Only set up polling for processing statuses
    const isProcessing = 
      iterationStatus === IterationStatus.TESTING || 
      iterationStatus === IterationStatus.ANALYZING
    
    if (!isProcessing || !iterationUuid) return
    
    // Check status every 5 seconds
    const intervalId = setInterval(() => {
      // If we have an iteration UUID, fetch its current status
      if (iterationUuid) {
        fetch(`/api/v1/iterations/${iterationUuid}`)
          .then(response => {
            if (response.ok) return response.json()
            throw new Error('Failed to fetch iteration status')
          })
          .then(data => {
            if (data && data.iteration && data.iteration.status) {
              setCurrentStatus(data.iteration.status)
              
              // If status is no longer processing, clear the interval
              if (
                data.iteration.status !== IterationStatus.TESTING && 
                data.iteration.status !== IterationStatus.ANALYZING
              ) {
                clearInterval(intervalId)
              }
            }
          })
          .catch(error => {
            console.error('Error checking iteration status:', error)
          })
      }
    }, 5000) // Poll every 5 seconds
    
    return () => clearInterval(intervalId)
  }, [iterationStatus, iterationUuid])
  
  if (
    currentStatus == IterationStatus.DELETED ||
    currentStatus == IterationStatus.UNTESTED
  ) {
    return <></>
  }
  
  const status = transformStatus(currentStatus)

  return (
    <div
      className={`c-iteration-processing-status --${status}`}
      role="status"
      aria-label="Processing status"
    >
      <Content status={status} />
    </div>
  )
}
