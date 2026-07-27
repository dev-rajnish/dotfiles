// ==UserScript==
// @name         Tokyo Night Universal Web Theme
// @namespace    http://qutebrowser.org/
// @version      2.3
// @description  Force Tokyo Night Dark theme on web pages while excluding WhatsApp Web
// @match        *://*/*
// @match        http://*/*
// @match        https://*/*
// @exclude      *://web.whatsapp.com/*
// @exclude      *://*.whatsapp.com/*
// @exclude      https://web.whatsapp.com/*
// @exclude      http://web.whatsapp.com/*
// @exclude      https://*.whatsapp.com/*
// @exclude      http://*.whatsapp.com/*
// @run-at       document-start
// @grant        none
// ==UserScript==

(function() {
    'use strict';

    // Robust check for WhatsApp Web (handles top window, subframes, iframes & cross-origin referrers)
    function isWhatsApp() {
        try {
            if (window.location && window.location.href && window.location.href.includes('whatsapp')) return true;
            if (window.location && window.location.hostname && window.location.hostname.includes('whatsapp')) return true;
            if (document.domain && document.domain.includes('whatsapp')) return true;
            if (window.top && window.top.location && window.top.location.href && window.top.location.href.includes('whatsapp')) return true;
        } catch (e) {
            if (document.referrer && document.referrer.includes('whatsapp')) return true;
        }
        return false;
    }

    if (isWhatsApp()) {
        return;
    }

    const universalCss = `
        /* Force root color scheme */
        :root {
            color-scheme: dark !important;
            --tokyo-bg: #1a1b26 !important;
            --tokyo-card: #16161e !important;
            --tokyo-fg: #a9b1d6 !important;
            --tokyo-cyan: #0db9d7 !important;
            --tokyo-blue: #7aa2f7 !important;
            --tokyo-purple: #bb9af7 !important;
        }

        /* Primary page containers */
        html, body, div, header, nav, footer, main, article, section, aside, form, table, tr, td, th, ul, ol, li, pre, code, iframe {
            background-color: #1a1b26 !important;
            color: #a9b1d6 !important;
            border-color: #2f3549 !important;
        }

        /* Body & Root fallback */
        html, body {
            background: #1a1b26 !important;
            color: #a9b1d6 !important;
        }

        /* Paragraphs and Text */
        p, span, li, dt, dd, td, th, label, small, b, strong, i, em, blockquote {
            color: #a9b1d6 !important;
        }

        /* Headings */
        h1, h2, h3, h4, h5, h6 {
            color: #0db9d7 !important;
        }

        /* Links */
        a, a *, a:link, a:link * {
            color: #7aa2f7 !important;
        }
        a:visited, a:visited * {
            color: #bb9af7 !important;
        }
        a:hover, a:hover * {
            color: #b4f9f8 !important;
        }

        /* Form elements & Buttons */
        input, textarea, select, button, option {
            background-color: #16161e !important;
            color: #c0caf5 !important;
            border: 1px solid #444b6a !important;
        }

        /* Code blocks */
        pre, code, kbd, samp {
            background-color: #16161e !important;
            color: #9ece6a !important;
            border: 1px solid #2f3549 !important;
        }

        /* Tables & Lists */
        table, tr, td, th, fieldset, legend {
            background-color: #1a1b26 !important;
            border-color: #2f3549 !important;
        }

        /* Universal borders */
        * {
            border-color: #2f3549 !important;
        }

        /* Scrollbars */
        ::-webkit-scrollbar {
            width: 10px !important;
            height: 10px !important;
            background-color: #1a1b26 !important;
        }
        ::-webkit-scrollbar-thumb {
            background-color: #2f3549 !important;
            border-radius: 5px !important;
        }
    `;

    function applyTheme() {
        let style = document.getElementById('tokyo-night-theme-style');
        if (!style) {
            style = document.createElement('style');
            style.id = 'tokyo-night-theme-style';
            style.type = 'text/css';
            style.appendChild(document.createTextNode(universalCss));
        }
        
        const target = document.head || document.documentElement;
        if (target && target.lastElementChild !== style) {
            target.appendChild(style);
        }
    }

    applyTheme();

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', applyTheme);
    } else {
        applyTheme();
    }

    const observer = new MutationObserver(applyTheme);
    if (document.documentElement) {
        observer.observe(document.documentElement, { childList: true, subtree: true });
    }
})();
