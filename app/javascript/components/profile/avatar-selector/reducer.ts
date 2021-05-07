import ReactCrop from 'react-image-crop'
import { Status, CROP_DEFAULTS } from '../AvatarSelector'

export type State = {
  avatarUrl: string
  imageToCrop: string | null
  croppedImage: Blob | null
  status: Status
  cropSettings: ReactCrop.Crop
}

export type Action =
  | { type: 'crop.start'; payload: { imageToCrop: string } }
  | { type: 'crop.changed'; payload: { cropSettings: ReactCrop.Crop } }
  | { type: 'crop.finished'; payload: { croppedImage: Blob } }
  | { type: 'crop.redo' }
  | { type: 'crop.cancelled' }
  | { type: 'avatar.uploaded'; payload: { avatarUrl: string } }

export function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'avatar.uploaded':
      return {
        avatarUrl: action.payload.avatarUrl,
        imageToCrop: null,
        croppedImage: null,
        status: 'initialized',
        cropSettings: CROP_DEFAULTS,
      }
    case 'crop.start':
      return {
        ...state,
        imageToCrop: action.payload.imageToCrop,
        status: 'cropping',
        cropSettings: CROP_DEFAULTS,
      }
    case 'crop.changed':
      return {
        ...state,
        cropSettings: action.payload.cropSettings,
      }
    case 'crop.finished':
      return {
        ...state,
        status: 'cropFinished',
        croppedImage: action.payload.croppedImage,
      }
    case 'crop.redo':
      return {
        ...state,
        status: 'cropping',
      }
    case 'crop.cancelled':
      return {
        ...state,
        status: 'initialized',
        imageToCrop: null,
      }
  }
}
