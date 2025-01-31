import { DirectUpload } from "@rails/activestorage"

document.addEventListener("DOMContentLoaded", () => {
  const input = document.querySelector('input[type="file"][data-direct-upload-url]')
  if (input) {
    input.addEventListener("change", (event) => {
      const files = event.target.files
      Array.from(files).forEach(file => {
        const upload = new DirectUpload(file, input.dataset.directUploadUrl)
        upload.create((error, blob) => {
          if (error) {
            console.error(error)
          } else {
            const hiddenField = document.createElement("input")
            hiddenField.setAttribute("type", "hidden")
            hiddenField.setAttribute("value", blob.signed_id)
            hiddenField.name = input.name
            document.querySelector("form").appendChild(hiddenField)
          }
        })
      })
    })
  }
})