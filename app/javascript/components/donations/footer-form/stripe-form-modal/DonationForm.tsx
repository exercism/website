import React, { useCallback, useState } from 'react'
import { StripeForm } from '../../StripeForm'
import { ExercismStripeElements } from '../../ExercismStripeElements'
import currency from 'currency.js'

// This element seems to be unused
// export const DonationForm = ({
//   amount,
//   onCancel,
//   onSuccess,
//   onSettled,
//   onProcessing,
//   userSignedIn,
//   captchaRequired,
//   recaptchaSiteKey,
//   confirmParamsReturnUrl,
// }: {
//   amount: currency
//   onSuccess: () => void
//   onProcessing: () => void
//   onSettled: () => void
//   onCancel: () => void
//   userSignedIn: boolean
//   captchaRequired: boolean
//   recaptchaSiteKey: string
//   confirmParamsReturnUrl: string
// }): JSX.Element => {
//   const [isProcessing, setIsProcessing] = useState(false)

//   const handleProcessing = useCallback(() => {
//     onProcessing()
//     setIsProcessing(true)
//   }, [onProcessing])

//   const handleSettled = useCallback(() => {
//     onSettled()
//     setIsProcessing(false)
//   }, [onSettled])

//   return (
//     <ExercismStripeElements amount={amount.intValue}>
//       <StripeForm
//         userSignedIn={userSignedIn}
//         captchaRequired={captchaRequired}
//         recaptchaSiteKey={recaptchaSiteKey}
//         paymentIntentType="payment"
//         amount={amount}
//         onSuccess={onSuccess}
//         onProcessing={handleProcessing}
//         onSettled={handleSettled}
//         confirmParamsReturnUrl={confirmParamsReturnUrl}
//       />
//       <button
//         type="button"
//         className="btn-enhanced btn-s"
//         onClick={onCancel}
//         disabled={isProcessing}
//       >
//         Cancel
//       </button>
//     </ExercismStripeElements>
//   )
// }
