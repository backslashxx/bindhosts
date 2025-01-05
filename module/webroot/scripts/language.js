import { execCommand, activeOverlay, linkRedirect } from './index.js';

const languageMenu = document.querySelector('.language-menu');

export let translations = {};
let currentLang = 'en-US';
let availableLanguages = ['en-US'];

// Function to check for available language
export async function initializeAvailableLanguages() {
    try {
        const multiLang = await execCommand("find /data/adb/modules/bindhosts/webroot/locales -type f -name '*.json' ! -name 'A-template.json' -exec basename -s .json {} \\;");
        availableLanguages = multiLang.trim().split('\n');
        generateLanguageMenu();
    } catch (error) {
        console.error('Failed to fetch available languages:', error);
        availableLanguages = ['en-US'];
    }
}

// Function to detect user's default language
export function detectUserLanguage() {
    const userLang = navigator.language || navigator.userLanguage;
    const langCode = userLang.split('-')[0];
    if (availableLanguages.includes(userLang)) {
        return userLang;
    } else if (availableLanguages.includes(langCode)) {
        return langCode;
    } else {
        return 'en-US';
    }
}

// Load translations dynamically based on the selected language
export async function loadTranslations(lang) {
    try {
        const response = await fetch(`/locales/${lang}.json`);
        translations = await response.json();
        applyTranslations();
    } catch (error) {
        console.error(`Error loading translations for ${lang}:`, error);
        if (lang !== 'en-US') {
            console.log("Falling back to English.");
            loadTranslations('en-US');
        }
    }
}

// Function to apply translations to all elements with data-i18n attributes
function applyTranslations() {
    document.querySelectorAll("[data-i18n]").forEach((el) => {
        const keyString = el.getAttribute("data-i18n");
        const translation = keyString.split('.').reduce((acc, key) => acc && acc[key], translations);
        if (translation) {
            if (el.hasAttribute("placeholder")) {
                el.setAttribute("placeholder", translation);
            } else {
                const existingHTML = el.innerHTML;
                const splitHTML = existingHTML.split(/<br>/);
                if (splitHTML.length > 1) {
                    el.innerHTML = `${translation}<br>${splitHTML.slice(1).join('<br>')}`;
                } else {
                    el.textContent = translation;
                }
            }
        }
    });
}

// Function to generate the language menu dynamically
async function generateLanguageMenu() {
    languageMenu.innerHTML = '';
    const languagePromises = availableLanguages.map(async (lang) => {
        try {
            const response = await fetch(`/locales/${lang}.json`);
            const data = await response.json();
            return { lang, name: data.language || lang };
        } catch (error) {
            console.error(`Error fetching language name for ${lang}:`, error);
            return { lang, name: lang };
        }
    });
    const languageData = await Promise.all(languagePromises);
    const sortedLanguages = languageData.sort((a, b) => a.name.localeCompare(b.name));
    sortedLanguages.forEach(({ lang, name }) => {
        const button = document.createElement('button');
        button.classList.add('language-option');
        button.setAttribute('data-lang', lang);
        button.textContent = name;
        languageMenu.appendChild(button);
    });
}

languageMenu.addEventListener("click", (e) => {
    if (e.target.classList.contains("language-option")) {
        const lang = e.target.getAttribute("data-lang");
        loadTranslations(lang);
        const overlay = document.getElementById('language-help');
        overlay.classList.remove("active");
        document.body.style.overflow = "";
        activeOverlay = null;
    }
});
