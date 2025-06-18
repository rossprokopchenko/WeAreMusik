// app/javascript/turbo_debug.js
import * as TurboModule from "@hotwired/turbo-rails";

console.log("Inside turbo_debug.js:");
console.log("TurboModule:", TurboModule);
console.log("TurboModule.default:", TurboModule.default);
console.log("window.Turbo (from inside module):", window.Turbo);

if (window.Turbo && window.Turbo.version) {
  console.log("!!! Turbo is globally available from inside the module!");
} else {
  console.error("!!! Turbo is NOT globally available from inside the module!");
}