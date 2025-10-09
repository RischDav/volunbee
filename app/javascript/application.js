import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import { Chart, registerables } from "chart.js"
import 'cookieconsent/build/cookieconsent.min.css';
import 'cookieconsent';

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// Registriere Chart.js global
Chart.register(...registerables)
window.Chart = Chart

document.addEventListener("DOMContentLoaded", function() {
  // Prüfe, ob bereits Einstellungen vorhanden sind
  const existingConsent = localStorage.getItem('volunbee_cookieconsent');
  if (existingConsent === 'dismissed') {
    // Lade gespeicherte Einstellungen
    const settings = JSON.parse(localStorage.getItem('volunbee_cookie_consent') || '{"necessary":true,"analytics":false,"marketing":false}');
    
    if (settings.analytics) {
      // Aktiviere Analytics
      console.log('Analytics aus gespeicherten Einstellungen aktiviert');
    }
    
    if (settings.marketing) {
      // Aktiviere Marketing
      console.log('Marketing aus gespeicherten Einstellungen aktiviert');
    }
    
    return; // Zeige Banner nicht an
  }

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
        "background": "#10B981",
        "text": "#ffffff",
        "border": "transparent"
      },
      "highlight": {
        "background": "#EF4444",
        "text": "#ffffff",
        "border": "transparent"
      }
    },
    "theme": "edgeless",
    "position": "bottom-left",
    "type": "opt-in",
    "layout": "block",
    "animateRevokable": false,
    "content": {
      "message": "🍪 Wir verwenden Cookies, um Ihnen die bestmögliche Erfahrung auf unserer Website zu bieten.",
      "dismiss": "Alle akzeptieren",
      "deny": "Alle ablehnen", 
      "link": "Einstellungen",
      "href": "#",
      "close": "✕",
      "policy": "Cookie-Richtlinie",
      "target": "_self"
    },
    "elements": {
      "messagelink": `
        <span id="cookieconsent:desc" class="cc-message">{{message}}</span>
        <div style="margin-top: 16px;">
          <a aria-label="Cookie-Einstellungen anpassen" role="button" tabindex="0" class="cookie-settings-btn" onclick="showCookieSettings(); return false;">{{link}}</a>
        </div>
      `,
    },
    "cookie": {
      "name": "volunbee_cookieconsent",
      "path": "/",
      "domain": "",
      "expiryDays": 365,
      "secure": true,
      "sameSite": "lax"
    },
    "onStatusChange": function(status, chosenBefore) {
      console.log('Cookie consent status:', status);
      
      if (status === 'deny') {
        // Alle optionalen Cookies ablehnen
        const settings = { necessary: true, analytics: false, marketing: false };
        localStorage.setItem('volunbee_cookie_consent', JSON.stringify(settings));
        
        const popup = document.querySelector('.cc-window');
        if (popup) {
          popup.style.transition = 'opacity 0.2s ease';
          popup.style.opacity = '0';
          setTimeout(() => {
            popup.style.display = 'none';
          }, 200);
        }
        
        // Zeige Footer-Button
        document.getElementById('footer-cookie-btn').style.display = 'block';
        
        console.log('Cookies wurden abgelehnt');
      } else if (status === 'allow') {
        // Alle Cookies akzeptieren
        const settings = { necessary: true, analytics: true, marketing: true };
        localStorage.setItem('volunbee_cookie_consent', JSON.stringify(settings));
        
        // Zeige Footer-Button
        document.getElementById('footer-cookie-btn').style.display = 'block';
        
        // Aktiviere alle Services
        console.log('Alle Cookies wurden akzeptiert');
        // Hier würdest du Analytics und Marketing aktivieren
      }
    },
    "onInitialise": function(status) {
      console.log('Cookie consent initialisiert mit Status:', status);
    }
  });
});

// Globale Funktion für Cookie-Einstellungen
window.showCookieSettings = function() {
  document.getElementById('cookie-settings-modal').style.display = 'flex';
  // Lade aktuelle Einstellungen
  const settings = JSON.parse(localStorage.getItem('volunbee_cookie_consent') || '{"necessary":true,"analytics":false,"marketing":false}');
  document.getElementById('analytics-cookies').checked = settings.analytics;
  document.getElementById('marketing-cookies').checked = settings.marketing;
};

import "./controllers"