import { useCallback, useReducer } from 'react'

export type CropProps = {
  aspect?: number
  width?: number
  height?: number
  x?: number
  y?: number
  unit?: Unit
}

export type State = {
  imageToCrop: string | null
  croppedImage: Blob | null
  status: Status
  cropSettings: CropProps
}

export type Action =
  | { type: 'crop.start'; payload: { imageToCrop: string } }
  | { type: 'crop.changed'; payload: { cropSettings: CropProps } }
  | { type: 'crop.finished'; payload: { croppedImage: Blob } }
  | { type: 'crop.redo' }
  | { type: 'crop.cancelled' }
  | { type: 'avatar.uploaded'; payload: { avatarUrl: string } }

type Status = 'initialized' | 'cropping' | 'cropFinished'

type Unit = 'px' | '%'

const CROP_DEFAULTS = {
  aspect: 1,
  height: 50,
  x: 25,
  y: 10,
  unit: '%',
} as const

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'avatar.uploaded':
      return {
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

export const useImageCrop = () => {
  const [state, dispatch] = useReducer(reducer, {
    status: 'initialized',
    cropSettings: CROP_DEFAULTS,
    imageToCrop: null,
    croppedImage: null,
  })

  const handleAttach = useCallback((e) => {
    const fileReader = new FileReader()

    fileReader.onloadend = () => {
      dispatch({
        type: 'crop.start',
        payload: {
          imageToCrop: fileReader.result as string,
        },
      })
    }

    fileReader.readAsDataURL(e.target.files[0])
  }, [])

  return { state, dispatch, handleAttach }
}
