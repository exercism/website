if (window.location.pathname === '/bootcamp/confirmed') {
  initialize()
}

async function initialize() {
  const queryString = window.location.search
  const urlParams = new URLSearchParams(queryString)
  const sessionId = urlParams.get('session_id')
  if (!sessionId) {
    // window.location.replace('/bootcamp/pay')
    return
  }
  const response = await fetch(
    `/bootcamp/stripe/session-status?session_id=${sessionId}`
  )
  const session = await response.json()

  if (session.status == 'open') {
    window.location.replace('/bootcamp/pay')
  } else if (session.status == 'complete') {
    document.getElementById('pending').classList.add('hidden')
    document.getElementById('success').classList.remove('hidden')
    document.getElementById('customer-email').textContent =
      session.customer_email
  }
}
