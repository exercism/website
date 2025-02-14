import React from 'react'
import { lazy, Suspense } from 'react'
import { initReact } from '../utils/react-bootloader'
import '@hotwired/turbo-rails'
import { camelizeKeysAs } from '@/utils/camelize-keys-as'

const SolveExercisePage = lazy(
  () => import('../components/bootcamp/SolveExercisePage/SolveExercisePage')
)
const DrawingPage = lazy(
  () => import('../components/bootcamp/DrawingPage/DrawingPage')
)
const CustomFunctionEditor = lazy(
  () =>
    import('../components/bootcamp/CustomFunctionEditor/CustomFunctionEditor')
)
const BootcampAffiliateCouponForm = lazy(
  () => import('@/components/settings/BootcampAffiliateCouponForm')
)

declare global {
  interface Window {
    turboLoaded: boolean
  }
}
// As we're sensitive to the order of things across different packs
// we set a window-level constant to record when turbo has loaded
// so that other packs that haven't yet rendered events can respond to them
document.addEventListener('turbo:load', () => (window.turboLoaded = true))

const mappings = {
  'bootcamp-solve-exercise-page': (
    data: SolveExercisePageProps
  ): JSX.Element => (
    <Suspense>
      <SolveExercisePage {...camelizeKeysAs<SolveExercisePageProps>(data)} />
    </Suspense>
  ),

  'bootcamp-drawing-page': (data: DrawingPageProps): JSX.Element => (
    <Suspense>
      <DrawingPage {...camelizeKeysAs<DrawingPageProps>(data)} />
    </Suspense>
  ),
  'bootcamp-custom-function-editor': (data): JSX.Element => (
    <Suspense>
      <CustomFunctionEditor data={data} />
    </Suspense>
  ),
  'settings-bootcamp-affiliate-coupon-form': (data: any) => (
    <Suspense>
      <BootcampAffiliateCouponForm
        context={data.context}
        insidersStatus={data.insiders_status}
        bootcampAffiliateCouponCode={data.bootcamp_affiliate_coupon_code}
        links={camelizeKeysAs<{
          insidersPath: string
          bootcampAffiliateCouponCode: string
        }>(data.links)}
      />
    </Suspense>
  ),
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact(mappings)
