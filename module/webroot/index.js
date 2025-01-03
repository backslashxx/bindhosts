import { initializeAvailableLanguages, detectUserLanguage, loadTranslations, translations } from './language.js';

const basePath = "/data/adb/bindhosts";

const filePaths = {
    custom: `${basePath}/custom.txt`,
    sources: `${basePath}/sources.txt`,
    blacklist: `${basePath}/blacklist.txt`,
    whitelist: `${basePath}/whitelist.txt`,
};

const cover = document.querySelector('.cover');
const headerBlock = document.querySelector('.header-block');
const header = document.querySelector('.header');
const actionButton = document.querySelector('.action-button');
const inputs = document.querySelectorAll('input');
const focusClass = 'input-focused';
const toggleContainer = document.getElementById('update-toggle-container');
const toggleVersion = document.getElementById('toggle-version');
const actionRedirectContainer = document.getElementById('action-redirect-container');
const actionRedirectStatus = document.getElementById('action-redirect');
const cronContainer = document.getElementById('cron-toggle-container');
const cronToggle = document.getElementById('toggle-cron');
const rippleClasses = ['#mode-btn', '.action-button', '#status-box', '.input-box-wrapper', '.add-btn', '.toggle-list', '.prompt.reboot', '.learn-more', '#reset-mode', '.language-option', '.language-improve'];

let clickCount = 0;
let timeout;
let clickTimeout;
let developerOption = false;
let disableTimeout;

// Function to add material design style ripple effect
function applyRippleEffect() {
    rippleClasses.forEach(selector => {
        document.querySelectorAll(selector).forEach(element => {
            element.addEventListener("pointerdown", function (event) {
                if (isScrolling) return;                
                const ripple = document.createElement("span");
                ripple.classList.add("ripple");

                // Calculate ripple size and position
                const rect = element.getBoundingClientRect();
                const width = rect.width;
                const size = Math.max(rect.width, rect.height);
                const x = event.clientX - rect.left - size / 2;
                const y = event.clientY - rect.top - size / 2;

                // Determine animation duration
                let duration = 0.2 + (width / 800) * 0.4;
                duration = Math.min(0.8, Math.max(0.2, duration));

                // Set ripple styles
                ripple.style.width = ripple.style.height = `${size}px`;
                ripple.style.left = `${x}px`;
                ripple.style.top = `${y}px`;
                ripple.style.animationDuration = `${duration}s`;
                ripple.style.transition = `opacity ${duration}s ease`;

                // Adaptive color
                const computedStyle = window.getComputedStyle(element);
                const bgColor = computedStyle.backgroundColor || "rgba(0, 0, 0, 0)";
                const textColor = computedStyle.color;
                const isDarkColor = (color) => {
                    const rgb = color.match(/\d+/g);
                    if (!rgb) return false;
                    const [r, g, b] = rgb.map(Number);
                    return (r * 0.299 + g * 0.587 + b * 0.114) < 96; // Luma formula
                };
                ripple.style.backgroundColor = isDarkColor(bgColor) ? "rgba(255, 255, 255, 0.2)" : "";

                // Append ripple and handle cleanup
                element.appendChild(ripple);
                const handlePointerUp = () => {
                    ripple.classList.add("end");
                    setTimeout(() => {
                        ripple.classList.remove("end");
                        ripple.remove();
                    }, duration * 1000);
                    element.removeEventListener("pointerup", handlePointerUp);
                    element.removeEventListener("pointercancel", handlePointerUp);
                };
                element.addEventListener("pointerup", handlePointerUp);
                element.addEventListener("pointercancel", handlePointerUp);
            });
        });
    });
}

// Function to read a file and display its content in the UI
async function loadFile(fileType) {
    checkMagisk();
    try {
        const content = await execCommand(`cat ${filePaths[fileType]}`);
        const lines = content
            .split("\n")
            .map(line => line.trim())
            .filter(line => line && !line.startsWith("#"));
        const listElement = document.getElementById(`${fileType}-list`);
        listElement.innerHTML = "";
        lines.forEach(line => {
            const listItem = document.createElement("li");
            listItem.innerHTML = `
                <span>${line}</span>
                <button class="delete-btn">
                    <i class="fa fa-trash"></i>
                </button>
            `;
            listElement.appendChild(listItem);
            listItem.querySelector(".delete-btn").addEventListener("click", () => removeLine(fileType, line));
        });
    } catch (error) {
        console.error(`Failed to load ${fileType} file: ${error}`);
    }
}

// Function to check if running in Magisk
async function checkMagisk() {
    try {
        const magiskEnv = await execCommand(`[ -f /data/adb/magisk/magisk ] && echo "OK"`);
        if (magiskEnv.trim() === "OK") {
            console.log("Running under magisk environment, displaying element.");
            actionRedirectContainer.style.display = "flex";
        } else {
            console.log("Not magisk, leaving action redirect element hidden.");
        }
    } catch (error) {
        console.error("Error while checking magisk", error);
    }
}

// Function to load the version from module.prop and load the version in the WebUI
async function getCurrentMode() {
    try {
        const command = "grep '^operating_mode=' /data/adb/modules/bindhosts/mode.sh | cut -d'=' -f2";
        const mode = await execCommand(command);
        updateMode(mode.trim());
    } catch (error) {
        console.error("Failed to read description from mode.sh:", error);
        updateMode("Error");
    }
}

// Function to load the version text dynamically in the WebUI
function updateMode(modeText) {
    const modeElement = document.getElementById('mode-text');
    modeElement.textContent = modeText;
}

// Function to load the version from module.prop and load the version in the WebUI
async function loadVersionFromModuleProp() {
    try {
        const command = "grep '^version=' /data/adb/modules/bindhosts/module.prop | cut -d'=' -f2";
        const version = await execCommand(command);
        updateVersion(version.trim());
    } catch (error) {
        console.error("Failed to read version from module.prop:", error);
        updateVersion("Error");
    }
}

// Function to load the version text dynamically in the WebUI
function updateVersion(versionText) {
    const versionElement = document.getElementById('version-text');
    versionElement.textContent = versionText;
}

// Function to check module update status
async function checkUpdateStatus() {
    try {
        const result = await execCommand("grep -q '^updateJson' /data/adb/modules/bindhosts/module.prop");
        toggleVersion.checked = !result;
    } catch (error) {
        toggleVersion.checked = false;
        console.error('Error checking update status:', error);
    }
}

// Function to check action redirect WebUI status
async function checkRedirectStatus() {
    try {
        const result = await execCommand("su -c '[ ! -f /data/adb/bindhosts/webui_setting.sh ] || grep -q '^magisk_webui_redirect=1' /data/adb/bindhosts/webui_setting.sh' ");
        actionRedirectStatus.checked = !result;
    } catch (error) {
        actionRedirectStatus.checked = false;
        console.error('Error checking action redirect status:', error);
    }
}

// Function to check cron status
async function checkCronStatus() {
    try {
        const result = await execCommand(`grep -q "bindhosts.sh" ${basePath}/crontabs/root`);
        cronToggle.checked = !result;
    } catch (error) {
        cronToggle.checked = false;
        console.error('Error checking cron status:', error);
    }
}

// Function to get the status from module.prop and update the status in the WebUI
async function updateStatusFromModuleProp() {
    try {
        const command = "grep '^description=' /data/adb/modules/bindhosts/module.prop | sed 's/description=status: //'";
        const description = await execCommand(command);
        updateStatus(description.trim());
    } catch (error) {
        console.error("Failed to read description from module.prop:", error);
        updateStatus("Error reading description from module.prop");
    }
}

// Function to update the status text dynamically in the WebUI
function updateStatus(statusText) {
    const statusElement = document.getElementById('status-text');
    statusElement.textContent = statusText;
}

// Function to handle adding input to the file
async function handleAdd(fileType, prompt) {
    const inputElement = document.getElementById(`${fileType}-input`);
    const inputValue = inputElement.value.trim();
    console.log(`Input value for ${fileType}: "${inputValue}"`);
    if (inputValue === "") {
        console.error("Input is empty. Skipping add operation.");
        return;
    }
    try {
        const fileContent = await execCommand(`cat ${filePaths[fileType]}`);
        const lines = fileContent.split('\n').map(line => line.trim()).filter(line => line !== "");
        if (lines.includes(inputValue)) {
            console.log(`"${inputValue}" is already in ${fileType}. Skipping add operation.`);
            showPrompt(prompt, false, 2000, `${inputValue}`);
            inputElement.value = "";
            return;
        }
        await execCommand(`echo "${inputValue}" >> ${filePaths[fileType]}`);
        console.log(`Added "${inputValue}" to ${fileType} successfully.`);
        inputElement.value = "";
        console.log(`Input box for ${fileType} cleared.`);
        loadFile(fileType);
    } catch (error) {
        console.error(`Failed to add "${inputValue}" to ${fileType}: ${error}`);
    }
}

// Function to remove a line from a file
async function removeLine(fileType, lineContent) {
    try {
        const content = await execCommand(`cat ${filePaths[fileType]}`);
        const updatedContent = content
            .split("\n")
            .filter(line => line.trim() !== lineContent)
            .join("\n");

        await execCommand(`echo "${updatedContent}" > ${filePaths[fileType]}`);
        loadFile(fileType);
    } catch (error) {
        console.error(`Failed to remove line from ${fileType}: ${error}`);
    }
}

// Help event listener
export let activeOverlay = null;
function setupHelpMenu() {
    const helpButtons = document.querySelectorAll(".help-btn");
    const overlays = document.querySelectorAll(".overlay");
    helpButtons.forEach(button => {
        button.addEventListener("click", () => {
            const type = button.dataset.type;
            const overlay = document.getElementById(`${type}-help`);
            if (overlay) {
                openOverlay(overlay);
            }
        });
    });
    overlays.forEach(overlay => {
        const closeButton = overlay.querySelector(".close-btn");
        const languageContainer = document.getElementById('language-container');
        const language = document.getElementById('language-help');

        if (closeButton) {
            closeButton.addEventListener("click", () => closeOverlay(overlay));
        }

        if (languageContainer) {
            languageContainer.addEventListener('click', () => {
            openOverlay(language);
            });
        }

        overlay.addEventListener("click", (e) => {
            if (e.target === overlay) {
                closeOverlay(overlay);
            }
        });
    });
    function openOverlay(overlay) {
        if (activeOverlay) closeOverlay(activeOverlay);
        overlay.classList.add("active");
        document.body.style.overflow = "hidden";
        activeOverlay = overlay;
    }
    function closeOverlay(overlay) {
        overlay.classList.remove("active");
        document.body.style.overflow = "";
        activeOverlay = null;
    }
}

// Run bindhosts.sh --action
async function executeActionScript() {
    try {
        showPrompt("global.executing", true, 50000);
        await new Promise(resolve => setTimeout(resolve, 200));
            const command = "su -c 'sh /data/adb/modules/bindhosts/bindhosts.sh --action'";
            const output = await execCommand(command);
            const lines = output.split("\n");
            lines.forEach(line => {
                if (line.includes("[+] hosts file reset!")) {
                    showPrompt("global.reset", true, undefined, "[+]");
                } else if (line.includes("[+]")) {
                    showPrompt(line, true);
                } else if (line.includes("[x] unwritable")) {
                    showPrompt("global.unwritable", false, undefined, "[×]");
                } else if (line.includes("[x]")) {
                    showPrompt(line, false);
                } else if (line.includes("[*] not running")) {
                    showPrompt("global.disabled", false, undefined, "[*]");
                } else if (line.includes("[*] please reset")) {
                    showPrompt("global.adaway", false, undefined, "[*]");
                } else if (line.includes("[*]")) {
                    showPrompt(line, false);
                }
            });
            await updateStatusFromModuleProp();
    } catch (error) {
        showPrompt("global.execute_error", false, undefined, undefined, error);
        console.error("Failed to execute action script:", error);
    }
}

// Funtion to determine state of developer option
async function checkDevOption() {
    const filePath = "/data/adb/bindhosts/mode_override.sh";
    const fileExists = await execCommand(`[ -f ${filePath} ] && echo 'exists' || echo 'not-exists'`);

    if (fileExists.trim() === "exists") {
        developerOption = true;
    }
}

// Determine mode button behavior of mode button depends on developer option
document.getElementById("mode-btn").addEventListener("click", async () => {
    await checkDevOption();
    if (developerOption) {
        openOverlay(document.getElementById("mode-menu"));
    } else {
        linkRedirect('https://github.com/backslashxx/bindhosts/blob/master/Documentation/modes.md#bindhosts-operating-modes');
    }
});

// Function to redirect link on external browser
export async function linkRedirect(link) {
    try {
        await execCommand(`am start -a android.intent.action.VIEW -d ${link}`);
    } catch (error) {
        console.error('Error redirect link:', error);
    }
}

// Event listener to enable developer option
document.getElementById("status-box").addEventListener("click", async (event) => {  
    clickCount++;
    clearTimeout(clickTimeout);
    clickTimeout = setTimeout(() => {
        clickCount = 0;
    }, 2000);
    if (clickCount === 5) {
        clickCount = 0;
        await checkDevOption();
        if (!developerOption) {
            try {
                developerOption = true;
                showPrompt("global.dev_opt", true);
            } catch (error) {
                console.error("Error enabling developer option:", error);
                showPrompt("global.dev_opt_fail", false);
            }
        } else {
            showPrompt("global.dev_opt_true", true);
        }
    }
});

// Save mode option
async function saveModeSelection(mode) {
    try {
        if (mode === "reset") {
            await execCommand("rm -f /data/adb/bindhosts/mode_override.sh");
            closeOverlay("mode-menu");
        } else {
            await execCommand(`echo "mode=${mode}" > /data/adb/bindhosts/mode_override.sh`);
        }
        showPrompt("global.reboot", true, 4000);
        await updateModeSelection();
    } catch (error) {
        console.error("Error saving mode selection:", error);
    }
}

// Update radio button state based on current mode
async function updateModeSelection() {
    try {
        const fileExists = await execCommand("[ -f /data/adb/bindhosts/mode_override.sh ] && echo 'exists' || echo 'not-exists'");
        if (fileExists.trim() === "not-exists") {
            document.querySelectorAll("#mode-options input").forEach((input) => {
                input.checked = false;
            });
            return;
        }
        const content = await execCommand("cat /data/adb/bindhosts/mode_override.sh");
        const currentMode = content.trim().match(/mode=(\d+)/)?.[1] || null;
        document.querySelectorAll("#mode-options input").forEach((input) => {
            input.checked = input.value === currentMode;
        });
    } catch (error) {
        console.error("Error updating mode selection:", error);
    }
}

// function to open and close mode option
function openOverlay(overlay) {
    updateModeSelection();
    overlay.classList.add("active");
    document.body.style.overflow = "hidden";
    document.querySelector('.learn-more').addEventListener("click", function() {
        linkRedirect('https://github.com/backslashxx/bindhosts/blob/master/Documentation/modes.md#bindhosts-operating-modes');
    });
}
document.getElementById("mode-menu").addEventListener("click", (e) => {
    if (e.target === e.currentTarget) {
        closeOverlay("mode-menu");
    }
});
async function closeOverlay(id) {
    const overlay = document.getElementById(id);
    overlay.classList.remove("active");
    document.body.style.overflow = "";
    if (id === "mode-menu") {
        try {
            const content = await execCommand("cat /data/adb/bindhosts/mode_override.sh || echo ''");
            if (content.trim() === "") {
                await execCommand("rm -f /data/adb/bindhosts/mode_override.sh");
                console.log("Removed empty mode_override.sh file");
            }
        } catch (error) {
            console.error("Error checking or removing empty file:", error);
        }
    }
}

// Function to show the prompt with a success or error message
function showPrompt(key, isSuccess = true, duration = 2000, preValue = "", postValue = "") {
    const prompt = document.getElementById('prompt');
    const message = key.split('.').reduce((acc, k) => acc && acc[k], translations) || key;
    const finalMessage = `${preValue} ${message} ${postValue}`.trim();
    prompt.textContent = finalMessage;
    prompt.classList.toggle('error', !isSuccess);

    if (window.promptTimeout) {
        clearTimeout(window.promptTimeout);
    }
    if (message.includes("Reboot to take effect")) {
        prompt.classList.add('reboot');
        applyRippleEffect();
        let countdownActive = false;
        prompt.onclick = () => {
            if (countdownActive) return;
            countdownActive = true;
            let countdown = 3;
            prompt.textContent = `Rebooting in ${countdown}...`;
            const countdownInterval = setInterval(() => {
                countdown--;
                if (countdown > 0) {
                    prompt.textContent = `Rebooting in ${countdown}...`;
                } else {
                    clearInterval(countdownInterval);
                    countdownActive = false;
                    execCommand("svc power reboot").catch(error => {
                        console.error("Failed to execute reboot command:", error);
                    });
                }
            }, 1000);
        };
    } else {
        prompt.classList.remove('reboot');
    }

    setTimeout(() => {
        if (typeof ksu !== 'undefined' && ksu.mmrl) {
            prompt.style.transform = 'translateY(calc((var(--window-inset-bottom) + 60%) * -1))';
        } else {
            prompt.style.transform = 'translateY(-60%)';
        }
        window.promptTimeout = setTimeout(() => {
            prompt.style.transform = 'translateY(100%)';
        }, duration);
    }, 100);
}

// Prevent input box blocked by keyboard
inputs.forEach(input => {
    input.addEventListener('focus', event => {
        document.body.classList.add(focusClass);
        setTimeout(() => {
            const offsetAdjustment = window.innerHeight * 0.1;
            const targetPosition = event.target.getBoundingClientRect().top + window.scrollY;
            const adjustedPosition = targetPosition - (window.innerHeight / 2) + offsetAdjustment;
            window.scrollTo({
                top: adjustedPosition,
                behavior: 'smooth',
            });
        }, 100);
    });
    input.addEventListener('blur', () => {
        document.body.classList.remove(focusClass);
    });
});

// Scroll event
let lastScrollY = window.scrollY;
let isScrolling = false;
let scrollTimeout;
const scrollThreshold = 25;
window.addEventListener('scroll', () => {
    isScrolling = true;
    clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(() => {
        isScrolling = false;
    }, 200);
    if (window.scrollY > lastScrollY && window.scrollY > scrollThreshold) {
        headerBlock.style.transform = 'translateY(-80px)';
        header.style.transform = 'translateY(-80px)';
        if (typeof ksu !== 'undefined' && ksu.mmrl) {
            actionButton.style.transform = 'translateY(calc(var(--window-inset-bottom) + 90px))';
        } else {
            actionButton.style.transform = 'translateY(90px)';
        }
    } else if (window.scrollY < lastScrollY) {
        headerBlock.style.transform = 'translateY(0)';
        header.style.transform = 'translateY(0)';
        actionButton.style.transform = 'translateY(0)';
    }
    lastScrollY = window.scrollY;
});

// Attach event listener for action button
document.getElementById("actionButton").addEventListener("click", executeActionScript);

// Attach event listeners to the add buttons
function attachAddButtonListeners() {
    const elements = [
        { id: "custom-input", type: "custom", fail: "custom.prompt_fail" },
        { id: "sources-input", type: "sources", fail: "source.prompt_fail" },
        { id: "blacklist-input", type: "blacklist", fail: "blacklist.prompt_fail" },
        { id: "whitelist-input", type: "whitelist", fail: "whitelist.prompt_fail" }
    ];
    elements.forEach(({ id, type, fail }) => {
        const inputElement = document.getElementById(id);
        const buttonElement = document.getElementById(`${type}-add`);
        if (inputElement) {
            inputElement.addEventListener("keypress", (e) => {
                if (e.key === "Enter") handleAdd(type, fail);
            });
        }
        if (buttonElement) {
            buttonElement.addEventListener("click", () => handleAdd(type, fail));
        }
    });
}

// Attach event listeners for mode options
document.getElementById("mode-options").addEventListener("change", (event) => {
    const selectedMode = event.target.value;
    saveModeSelection(selectedMode);
});

// Attach event listener for reset button
document.getElementById("reset-mode").addEventListener("click", () => {
    saveModeSelection("reset");
});

// Event listener for the update toggle switch
toggleContainer.addEventListener('click', async function () {
    try {
        const result = await execCommand("su -c 'sh /data/adb/modules/bindhosts/bindhosts.sh --toggle-updatejson'");
        const lines = result.split("\n");
        lines.forEach(line => {
            if (line.includes("[+]")) {
                showPrompt("control_panel.update_true", true, undefined, "[+]");
            } else if (line.includes("[x]")) {
                showPrompt("control_panel.update_false", false, undefined, "[×]");
            }
        });
        checkUpdateStatus();
    } catch (error) {
        console.error("Failed to toggle update", error);
    }
});

// Event listener for the action redirect switch
actionRedirectContainer.addEventListener('click', async function () {
    try {
        await execCommand(`su -c 'echo "magisk_webui_redirect=${actionRedirectStatus.checked ? 0 : 1}" > /data/adb/bindhosts/webui_setting.sh'`);
        if (actionRedirectStatus.checked) {
            showPrompt("control_panel.action_prompt_false", false, undefined, "[×]");
        } else {
            showPrompt("control_panel.action_prompt_true", true, undefined, "[+]");
        }
        checkRedirectStatus();
    } catch (error) {
        console.error("Failed to execute change status", error);
    }
});

// Event listener for the cron toggle switch
cronContainer.addEventListener('click', async function () {
    try {
        let command;
        if (cronToggle.checked) {
            command = "su -c 'sh /data/adb/modules/bindhosts/bindhosts.sh --disable-cron'";
        } else {
            command = "su -c 'sh /data/adb/modules/bindhosts/bindhosts.sh --enable-cron'";
        }
        const result = await execCommand(command);
        const lines = result.split("\n");
        lines.forEach(line => {
            if (line.includes("[+]")) {
                showPrompt("control_panel.cron_true", true, undefined, "[+]");
            } else if (line.includes("[x]")) {
                showPrompt("control_panel.cron_false", false, undefined, "[×]");
            }
        });
        checkCronStatus();
    } catch (error) {
        console.error("Failed to toggle cron", error);
    }
});

// Initial load
window.onload = () => {
    adjustHeaderForMMRL();
    ["custom", "sources", "blacklist", "whitelist"].forEach(loadFile);
    attachAddButtonListeners();
    attachHelpButtonListeners();
};
document.addEventListener('DOMContentLoaded', async () => {
    await initializeAvailableLanguages();
    const userLang = detectUserLanguage();
    await loadTranslations(userLang);
    cover.style.display = "none";
    setupHelpMenu();
    await getCurrentMode();
    await updateStatusFromModuleProp();
    await loadVersionFromModuleProp();
    applyRippleEffect();
    checkUpdateStatus();
    checkRedirectStatus();
    checkCronStatus();
});

// Function to check if running in MMRL
function adjustHeaderForMMRL() {
    if (typeof ksu !== 'undefined' && ksu.mmrl) {
        console.log("Running in MMRL");
        header.style.top = 'var(--window-inset-top)';
        actionButton.style.bottom = 'calc(var(--window-inset-bottom) + 25px)';
        headerBlock.style.display = 'block';
    }
}

// Execute shell commands
export async function execCommand(command) {
    return new Promise((resolve, reject) => {
        const callbackName = `exec_callback_${Date.now()}`;
        window[callbackName] = (errno, stdout, stderr) => {
            delete window[callbackName];
            if (errno === 0) {
                resolve(stdout);
            } else {
                console.error(`Error executing command: ${stderr}`);
                reject(stderr);
            }
        };
        try {
            ksu.exec(command, "{}", callbackName);
        } catch (error) {
            console.error(`Execution error: ${error}`);
            reject(error);
        }
    });
}
