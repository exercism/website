document.addEventListener(
  'turbo:load',
  function (event) {
    window.dataLayer = window.dataLayer || []
    function gtag() {
      dataLayer.push(arguments)
    }
    gtag('js', new Date())
    gtag('config', 'AW-303924066')
  },
  false
)
