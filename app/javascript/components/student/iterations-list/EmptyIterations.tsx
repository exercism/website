import React from 'react'
import {
  ProminentLink,
  CopyToClipboardButton,
  GraphicalIcon,
  FormButton,
} from '../../common'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../../FetchingBoundary'
import { redirectTo } from '../../../utils/redirect-to'
import { Exercise } from '../IterationsList'

type Links = {
  startExercise: string
  solvingExercisesLocally: string
}

type Solution = {
  links: {
    exercise: string
  }
}

const DEFAULT_ERROR = new Error('Unable to start exercise')

export const EmptyIterations = ({
  exercise,
  links,
}: {
  exercise: Exercise
  links: Links
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<Solution>(
    () => {
      const { fetch } = sendRequest({
        endpoint: links.startExercise,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: (solution) => {
        if (!isMountedRef.current) {
          return
        }

        redirectTo(solution.links.exercise)
      },
    }
  )

  return (
    <div className="lg-container container">
      <section className="zero-state">
        <h2>You haven’t submitted any iterations yet.</h2>
        <p>
          You’ll get to see all your iterations with test results and automated
          feedback once you submit a solution.
        </p>
        <div className="box">
          {exercise.hasTestRunner ? (
            <div className="editor">
              <h4>Via Exercism Editor</h4>
              <FormButton
                status={status}
                onClick={() => mutation()}
                type="button"
                className="editor-btn btn-primary btn-m"
              >
                <GraphicalIcon icon="editor" />
                <span>Start in Editor</span>
              </FormButton>
              <FetchingBoundary
                status={status}
                error={error}
                defaultError={DEFAULT_ERROR}
              />
            </div>
          ) : null}
          <div className="cli">
            <h4>Work locally (via CLI)</h4>
            <CopyToClipboardButton textToCopy={exercise.downloadCmd} />
          </div>
        </div>
        <ProminentLink
          link={links.solvingExercisesLocally}
          text="Learn more about solving exercises locally"
        />
      </section>
    </div>
  )
}
