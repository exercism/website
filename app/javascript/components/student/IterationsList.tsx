import React, { useEffect, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { Loading } from '../common'
import { Iteration } from '../types'
import { IterationReport } from './iterations-list/IterationReport'
import { EmptyIterations } from './iterations-list/EmptyIterations'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { SolutionChannel } from '../../channels/solutionChannel'

export type Exercise = {
  title: string
  slug: string
  downloadCmd: string
  hasTestRunner: boolean
}

export type Track = {
  title: string
  slug: string
  iconUrl: string
  highlightjsLanguage: string
  indentSize: number
}

export type Links = {
  getMentoring: string
  automatedFeedbackInfo: string
  startExercise: string
  solvingExercisesLocally: string
  toolingHelp: string
}

export type IterationsListRequest = {
  endpoint: string
  options: {
    initialData: {
      iterations: readonly Iteration[]
    }
  }
}

export const getCacheKey = (
  trackSlug: string,
  exerciseSlug: string
): string => {
  return `iterations-${trackSlug}-${exerciseSlug}`
}

export default function IterationsList({
  solutionUuid,
  request,
  exercise,
  track,
  links,
}: {
  solutionUuid: string
  request: IterationsListRequest
  exercise: Exercise
  track: Track
  links: Links
}): JSX.Element {
  const [isOpen, setIsOpen] = useState<boolean[]>([])

  const queryClient = useQueryClient()
  const CACHE_KEY = getCacheKey(track.slug, exercise.slug)

  useEffect(() => {
    queryClient.setQueryData([CACHE_KEY], request.options.initialData)
  }, [])

  const { data: resolvedData } = usePaginatedRequestQuery<{
    iterations: readonly Iteration[]
  }>([CACHE_KEY], {
    ...request,
    options: { ...request.options, staleTime: 1000 },
  })

  const handleDelete = (deletedIteration: Iteration) => {
    queryClient.setQueryData<{ iterations: readonly Iteration[] }>(
      [CACHE_KEY],
      (result) => {
        if (!result) {
          return { iterations: [] }
        }

        return {
          ...result,
          iterations: result.iterations.map((i) =>
            i.uuid === deletedIteration.uuid ? deletedIteration : i
          ),
        }
      }
    )
  }

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { uuid: solutionUuid },
      (response) => {
        queryClient.setQueryData([CACHE_KEY], {
          iterations: response.iterations,
        })
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [CACHE_KEY, solutionUuid])

  useEffect(() => {
    if (
      !resolvedData ||
      !resolvedData.iterations ||
      resolvedData.iterations.length === 0
    ) {
      return
    }

    if (isOpen.length === 0) {
      setIsOpen(resolvedData.iterations.map((_, i) => i === 0))

      return
    }

    const newIterationsLength = resolvedData.iterations.length - isOpen.length

    if (newIterationsLength > 0) {
      const newIsOpen = Array.from(Array(newIterationsLength)).map((_, i) =>
        i === 0 ? !isOpen.some((o) => o === true) : false
      )

      setIsOpen([...newIsOpen, ...isOpen])
    }
  }, [isOpen, isOpen.length, resolvedData])

  if (!resolvedData) {
    return <Loading />
  }

  if (resolvedData.iterations.length === 0) {
    return <EmptyIterations links={links} exercise={exercise} />
  }

  return (
    <div className="lg-container container">
      <section className="iterations">
        {resolvedData.iterations
          .slice()
          .sort((it1: Iteration, it2: Iteration) => {
            return it2.idx > it1.idx ? 1 : -1
          })
          .map((iteration, index) => {
            return (
              <IterationReport
                key={index}
                iteration={iteration}
                exercise={exercise}
                track={track}
                links={links}
                isOpen={isOpen[index]}
                onExpanded={() => {
                  setIsOpen(isOpen.map((o, i) => (index === i ? true : o)))
                }}
                onCompressed={() => {
                  setIsOpen(isOpen.map((o, i) => (index === i ? false : o)))
                }}
                onDelete={handleDelete}
              />
            )
          })}
      </section>
    </div>
  )
}
