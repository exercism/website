// Handle Jiki signup form submission via AJAX
if (window.location.pathname === '/jiki') {
  const form = document.querySelector('form[action*="jiki/signup"]')
  const confirmationDiv = document.querySelector('#signup-confirmation')
  const submitButton = form?.querySelector('input[type="submit"]')

  if (form && confirmationDiv && submitButton) {
    form.addEventListener('submit', async (e) => {
      e.preventDefault()

      // Disable button during submission
      submitButton.disabled = true
      const originalButtonText = submitButton.value
      submitButton.value = 'Submitting...'

      try {
        const formData = new FormData(form)
        const response = await fetch(form.action, {
          method: 'POST',
          headers: {
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]')
              .content,
            Accept: 'application/json',
          },
          body: formData,
        })

        if (response.ok) {
          const data = await response.json()

          // Show confirmation div
          confirmationDiv.classList.remove('hidden')

          // Update button text
          submitButton.value = 'Preferences Saved 👍'
        } else {
          // Handle error response
          const errorData = await response.json().catch(() => ({}))
          const errorMessage =
            errorData.error?.message || 'Failed to save. Please try again.'
          alert(errorMessage)
          submitButton.value = originalButtonText
        }
      } catch (error) {
        console.error('Error submitting form:', error)
        alert('Something went wrong. Please try again.')
        submitButton.value = originalButtonText
      } finally {
        // Re-enable button
        submitButton.disabled = false
      }
    })
  }
}
