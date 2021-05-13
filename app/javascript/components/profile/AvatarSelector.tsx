import React, { useReducer } from 'react'
import 'react-image-crop/lib/ReactCrop.scss'
import { User } from '../types'
import { Modal } from '../modals/Modal'
import { InitializedStep } from './avatar-selector/InitializedStep'
import { CroppingStep } from './avatar-selector/CroppingStep'
import { CropFinishedStep } from './avatar-selector/CropFinishedStep'
import { reducer, State, Action } from './avatar-selector/reducer'

export type Status = 'initialized' | 'cropping' | 'cropFinished'

type Links = {
  update: string
}

type Unit = 'px' | '%'
export type CropProps = {
  aspect?: number
  height?: number
  x?: number
  y?: number
  unit?: Unit
}
export const CROP_DEFAULTS: Required<CropProps> = {
  aspect: 1,
  height: 50,
  x: 25,
  y: 10,
  unit: '%',
}

export const AvatarSelector = ({
  user,
  links,
}: {
  user: User
  links: Links
}): JSX.Element => {
  const [state, dispatch] = useReducer(reducer, {
    avatarUrl: user.avatarUrl,
    status: 'initialized',
    cropSettings: CROP_DEFAULTS,
    imageToCrop: null,
    croppedImage: null,
  })

  const modalOpen = state.status == 'cropping' || state.status == 'cropFinished'

  return (
    <div className="c-avatar-selector">
      <InitializedStep user={user} state={state} dispatch={dispatch} />
      {modalOpen ? (
        <Modal open={true} className="m-crop-avatar" onClose={() => {}}>
          {state.status == 'cropping' ? (
            <CroppingStep state={state} dispatch={dispatch} />
          ) : (
            <CropFinishedStep state={state} dispatch={dispatch} links={links} />
          )}
        </Modal>
      ) : null}
    </div>
  )
}
