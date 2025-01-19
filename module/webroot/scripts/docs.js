import { linkRedirect, applyRippleEffect, toast, developerOption, learnMore } from './index.js';

// Function to fetch documents
function getDocuments(link, fallbackLink, element) {
    fetch(link)
        .then(response => {
            if (!response.ok) {
                return fetch(fallbackLink).then(fallbackResponse => {
                    if (!fallbackResponse.ok) {
                        throw new Error(`Fallback link failed with status ${fallbackResponse.status}`);
                    }
                    return fallbackResponse.text();
                });
            }
            return response.text();
        })
        .then(data => {
            window.linkRedirect = linkRedirect;
            marked.setOptions({
                sanitize: true,
                walkTokens(token) {
                    if (token.type === 'link') {
                        const href = token.href;
                        const text = token.text;
                        if (text === href) {
                            token.type = "html";
                            token.text = `<span><p id="copy-link">${text}</p></span>`;
                        } else {
                            token.href = "javascript:void(0);";
                            token.type = "html";
                            token.text = `<a href="javascript:void(0);" onclick="linkRedirect('${href}')">${text}</a>`;
                        }
                    }
                }
            });
            const docsContent = document.getElementById(element);
            docsContent.innerHTML = marked.parse(data);
            addCopyToClipboardListeners();
            applyRippleEffect();
        })
        .catch(error => {
            console.error('Error fetching documents:', error);
            document.getElementById(element).textContent = 'Failed to load content: ' + error.message;
        });
}

// Make link tap to copy
function addCopyToClipboardListeners() {
    const sourceLinks = document.querySelectorAll("#copy-link");
    sourceLinks.forEach((element) => {
        element.addEventListener("click", function () {
            navigator.clipboard.writeText(element.innerText).then(() => {
                toast("Text copied to clipboard: " + element.innerText);
            }).catch(err => {
                console.error("Failed to copy text: ", err);
            });
        });
    });
}

// Setup documents menu
let activeDocs = null;
let docsButtonListeners = [];
export async function setupDocsMenu(docsLang) {
    docsButtonListeners.forEach(({ button, listener }) => {
        button.removeEventListener("click", listener);
    });
    docsButtonListeners = [];
    const originalDocsLang = `_${docsLang}`;
    const docsData = {
        source: {
            link: `https://raw.githubusercontent.com/bindhosts/bindhosts/master/Documentation/sources${originalDocsLang}.md`,
            fallbackLink: `https://raw.githubusercontent.com/bindhosts/bindhosts/master/Documentation/sources.md`,
            element: 'source-content',
        },
        translate: {
            link: `https://raw.githubusercontent.com/bindhosts/bindhosts/master/Documentation/localize${originalDocsLang}.md`,
            fallbackLink: `https://raw.githubusercontent.com/bindhosts/bindhosts/master/Documentation/localize.md`,
            element: 'translate-content',
        },
        modes: {
            link: `https://raw.githubusercontent.com/bindhosts/bindhosts/master/Documentation/modes${originalDocsLang}.md`,
            fallbackLink: `https://raw.githubusercontent.com/bindhosts/bindhosts/master/Documentation/modes.md`,
            element: 'modes-content',
        },
    };

    const docsButtons = document.querySelectorAll(".docs-btn");
    const docsOverlay = document.querySelectorAll(".docs");

    docsButtons.forEach(button => {
        const listener = () => {
            const type = button.dataset.type;
            const overlay = document.getElementById(`${type}-docs`);
            if (type === 'modes' && developerOption && !learnMore) return;
            openOverlay(overlay);
            const { link, fallbackLink, element } = docsData[type] || {};
            getDocuments(link, fallbackLink, element);
        };
        button.addEventListener("click", listener);
        docsButtonListeners.push({ button, listener });
    });

    docsOverlay.forEach(overlay => {
        const closeButton = overlay.querySelector(".close-docs-btn");
        if (closeButton) {
            closeButton.addEventListener("click", () => closeOverlay(overlay));
        }
        overlay.addEventListener("click", (e) => {
            if (e.target === overlay) {
                closeOverlay(overlay);
            }
        });
    });
}

function openOverlay(overlay) {
    if (activeDocs) closeOverlay(activeDocs);
    overlay.classList.add("active");
    document.body.style.overflow = "hidden";
    activeDocs = overlay;
}

function closeOverlay(overlay) {
    overlay.classList.remove("active");
    document.body.style.overflow = "";
    activeDocs = null;
}