{{flutter_js}}
{{flutter_build_config}}

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('atc_service_worker.js').catch((error) => {
      console.warn('ATC Exam service worker registration failed:', error);
    });
  });
}

_flutter.loader.load({
  serviceWorkerSettings: null,
});
