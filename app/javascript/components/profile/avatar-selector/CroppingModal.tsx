import React, { useCallback } from 'react'
import { State, Action } from './use-image-crop'
import { Modal } from '../../modals/Modal'
import { CroppingStep } from './cropping-modal/CroppingStep'
import { CropFinishedStep } from './cropping-modal/CropFinishedStep'
import 'react-image-crop/dist/ReactCrop.css'
import { User } from '../../types'

type Links = {
  update: string
}

export const CroppingModal = ({
  state,
  dispatch,
  onUpload,
  links,
}: {
  state: State
  dispatch: React.Dispatch<Action>
  onUpload: (user: User) => void
  links: Links
}): JSX.Element => {
  const handleClose = useCallback(() => null, [])

  let step

  switch (state.status) {
    case 'cropping':
      step = <CroppingStep state={state} dispatch={dispatch} />

      break
    case 'cropFinished':
      step = (
        <CropFinishedStep
          state={state}
          dispatch={dispatch}
          onUpload={onUpload}
          links={links}
        />
      )

      break
    default:
      step = undefined

      break
  }

  return (
    <Modal
      open={step !== undefined}
      onClose={handleClose}
      className="m-crop-avatar"
    >
      {step}
    </Modal>
  )
}
