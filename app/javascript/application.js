import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import 'cookieconsent/build/cookieconsent.min.css';
import 'cookieconsent';

// FIX: Sichere dispatchEvent vor cookieconsent
(function() {
  const originalDispatchEvent = window.dispatchEvent;
  if (typeof originalDispatchEvent === 'function') {
    window.dispatchEvent = function(element, type, eventInit) {
      if (!element || typeof element.dispatchEvent !== 'function') {
        console.warn('dispatchEvent called with invalid element:', element);
        return null;
      }
      return originalDispatchEvent.call(this, element, type, eventInit);
    };
  }
})();

Rails.start()
Turbolinks.start()
ActiveStorage.start()

document.addEventListener("DOMContentLoaded", function() {
  if (typeof window.cookieconsent === 'undefined' || !window.cookieconsent.initialise) {
    console.error('CookieConsent ist nicht verfügbar!');
    return;
  }

  window.cookieconsent.initialise({
    "palette": {
      "popup": {
        "background": "#ffffff",
        "text": "#374151",
        "border": "#E5E7EB"
      },
      "button": {
        "background": "#10B981", // Grün für "Akzeptieren"
        "text": "#ffffff",
        "border": "transparent"
      },
      "highlight": {
        "background": "#EF4444", // Rot für "Ablehnen"
        "text": "#ffffff",
        "border": "transparent"
      }
    },
    "theme": "edgeless",
    "position": "bottom-left", // Explizit unten links
    "type": "opt-in",
    "layout": "block",
    "animateRevokable": false, // Deaktiviert langsame Animationen
    "content": {
      "message": "🍪 Wir verwenden Cookies, um Ihnen die bestmögliche Erfahrung auf unserer Website zu bieten.",
      "dismiss": "Alle akzeptieren",
      "deny": "Ablehnen",
      "link": "Datenschutzerklärung",
      "href": "/datenschutz",
      "close": "✕",
      "policy": "Cookie-Richtlinie",
      "target": "_blank"
    },
    "cookie": {
      "name": "volunbee_cookieconsent",
      "path": "/",
      "domain": "",
      "expiryDays": 365,
      "secure": true,
      "sameSite": "lax"
    },
    // Schnellere Callbacks
    "onStatusChange": function(status, chosenBefore) {
      console.log('Cookie consent status:', status);
      
      // Sofortiges Ausblenden bei Ablehnung
      if (status === 'deny') {
        const popup = document.querySelector('.cc-window');
        if (popup) {
          popup.style.transition = 'opacity 0.2s ease';
          popup.style.opacity = '0';
          setTimeout(() => {
            popup.style.display = 'none';
          }, 200);
        }
        console.log('Cookies wurden abgelehnt');
      } else if (status === 'allow') {
        console.log('Cookies wurden akzeptiert');
      }
    },
    "onInitialise": function(status) {
      console.log('Cookie consent initialisiert mit Status:', status);
    },
    "onPopupOpen": function() {
      // Stelle sicher, dass Positionierung korrekt ist
      setTimeout(() => {
        const popup = document.querySelector('.cc-window');
        if (popup && window.innerWidth >= 768) {
          // Desktop: unten links
          popup.style.bottom = '20px';
          popup.style.left = '20px';
          popup.style.right = 'auto';
          popup.style.top = 'auto';
          popup.style.transform = 'none';
        } else if (popup) {
          // Mobile: unten mittig
          popup.style.bottom = '20px';
          popup.style.left = '50%';
          popup.style.right = 'auto';
          popup.style.top = 'auto';
          popup.style.transform = 'translateX(-50%)';
        }
      }, 50);
    }
  });
});

import "./controllers"