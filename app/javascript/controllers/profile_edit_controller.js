import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fileInput",
    "fileError",
    "biographyEditor",
    "biographyCount"
  ]

  static values = {
    biographyMaxLength: Number
  }

  connect() {
    if (this.hasFileInputTarget && this.hasFileErrorTarget) {
      this.fileInputTarget.addEventListener("change", this.validateFileSize.bind(this));
    }

    if (this.hasBiographyEditorTarget) {
      this.trixEditor = this.biographyEditorTarget.querySelector("trix-editor");
      if (this.trixEditor) {
        this.trixEditor.addEventListener("trix-change", this.updateBiographyCount.bind(this));
        this.updateBiographyCount();
      }
    }
  }

  validateFileSize() {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    const file = this.fileInputTarget.files[0];

    if (file && file.size > maxSizeInBytes) {
      this.fileErrorTarget.classList.remove("hidden");
      this.fileInputTarget.value = ""; // Clear invalid file

      setTimeout(() => {
        this.fileErrorTarget.classList.add("hidden");
      }, 5000);
    } else {
      this.fileErrorTarget.classList.add("hidden");
    }
  }

  updateBiographyCount() {
    const plainText = this.trixEditor.editor.getDocument().toString().trim();
    const remaining = Math.max(this.biographyMaxLengthValue - plainText.length, 0);

    if (plainText.length > this.biographyMaxLengthValue) {
      // Optionally, you can choose NOT to forcibly truncate here,
      // or implement a smarter truncation method to avoid cursor jump.
      // For now, just show remaining 0.
    }

    this.biographyCountTarget.textContent = remaining;
  }
}
