const basePath = "/data/adb/bindhosts";

const filePaths = {
    custom: `${basePath}/custom.txt`,
    sources: `${basePath}/sources.txt`,
    blacklist: `${basePath}/blacklist.txt`,
    whitelist: `${basePath}/whitelist.txt`,
};

const headerBlock = document.querySelector('.header-block');
const header = document.querySelector('.header');
const inputs = document.querySelectorAll('input');
const focusClass = 'input-focused';

let clickCount = 0;
let timeout;
let clickTimeout;
let developerOption = false;
let disableTimeout;

// Function to read a file and display its content in the UI
async function loadFile(fileType) {
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
        await getCurrentMode();
        await updateStatusFromModuleProp();
        await loadVersionFromModuleProp();
    } catch (error) {
        console.error(`Failed to load ${fileType} file: ${error}`);
    }
}

// Function to load the version from module.prop and load the version in the WebUI
async function getCurrentMode() {
    try {
        const command = "cat /data/adb/modules/bindhosts/mode.sh | grep '^operating_mode=' | cut -d'=' -f2";
        const mode = await execCommand(command);
        updateMode(mode.trim());
    } catch (error) {
        console.error("Failed to read description from mode.sh:", error);
        updateMode("Error reading description from mode.sh");
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
        const command = "cat /data/adb/modules/bindhosts/module.prop | grep '^version=' | cut -d'=' -f2";
        const version = await execCommand(command);
        updateVersion(version.trim());
    } catch (error) {
        console.error("Failed to read version from module.prop:", error);
        updateVersion("Error reading version from module.prop");
    }
}

// Function to load the version text dynamically in the WebUI
function updateVersion(versionText) {
    const versionElement = document.getElementById('version-text');
    versionElement.textContent = versionText;
}

// Function to get the status from module.prop and update the status in the WebUI
async function updateStatusFromModuleProp() {
    try {
        const command = "cat /data/adb/modules/bindhosts/module.prop | grep '^description=' | cut -d'=' -f2";
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
async function handleAdd(fileType) {
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
            showPrompt(`"${inputValue}" is already in ${fileType}.`, false);
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
document.addEventListener("DOMContentLoaded", () => {
    const helpButtons = document.querySelectorAll(".help-btn");
    const overlays = document.querySelectorAll(".overlay");
    let activeOverlay = null;
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

        if (closeButton) {
            closeButton.addEventListener("click", () => closeOverlay(overlay));
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
});

// Run action.sh
async function executeActionScript() {
    try {
        showPrompt("Script running...");
        setTimeout(async () => {
            const command = "su -c 'sh /data/adb/modules/bindhosts/action.sh'";
            const output = await execCommand(command);
            const lines = output.split("\n");
            lines.forEach(line => {
                if (line.includes("[+]")) {
                    showPrompt(line, true);
                } else if (line.includes("[x]")) {
                    showPrompt(line, false);
                } else if (line.includes("[*]")) {
                    showPrompt(line, false);
                } else if (line.includes("[%]")) {
                    showPrompt(line, true);
                }
            });
            await updateStatusFromModuleProp();
        }, 1000);
    } catch (error) {
        console.error("Failed to execute action script:", error);
        showPrompt(`Error executing action script: ${error}`, false);
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
        window.open("https://github.com/backslashxx/bindhosts/blob/master/Documentation/modes.md#bindhosts-operating-modes", "_blank");
    }
});

// Event listener to enable developer option
document.getElementById("status-box").addEventListener("click", async () => {
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
                showPrompt("Developer option enabled", true);
            } catch (error) {
                console.error("Error enabling developer option:", error);
                showPrompt("Error enabling developer option", false);
            }
        } else {
            showPrompt("Developer option already enabled", true);
        }
    }
});

// Save mode option
async function saveModeSelection(mode) {
    try {
        if (mode === "reset") {
            await execCommand("rm -f /data/adb/bindhosts/mode_override.sh");
        } else {
            await execCommand(`echo "mode=${mode}" > /data/adb/bindhosts/mode_override.sh`);
        }
        showPrompt("Reboot to take effect, tap to reboot", true);
        await updateModeSelection();
        closeOverlay("mode-menu");
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
    overlay.classList.add("active");
    document.body.style.overflow = "hidden";
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
function showPrompt(message, isSuccess = true) {
    const prompt = document.getElementById('prompt');
    prompt.textContent = message;
    prompt.classList.toggle('error', !isSuccess);

    if (window.promptTimeout) {
        clearTimeout(window.promptTimeout);
    }

    if (message.includes("Reboot to take effect")) {
        prompt.classList.add('pointer');
        prompt.onclick = () => {
            let countdown = 3;
            prompt.textContent = `Rebooting in ${countdown}...`;
            const countdownInterval = setInterval(() => {
                countdown--;
                if (countdown > 0) {
                    prompt.textContent = `Rebooting in ${countdown}...`;
                } else {
                    clearInterval(countdownInterval);
                    execCommand("svc power reboot").catch(error => {
                        console.error("Failed to execute reboot command:", error);
                    });
                }
            }, 1000);
        };
    } else {
        prompt.classList.remove('pointer');
        prompt.onclick = null;
    }

    setTimeout(() => {
        prompt.classList.add('visible');
        prompt.classList.remove('hidden');
        const timeoutDuration = message.includes('running') ? 10000 : 3000;
        window.promptTimeout = setTimeout(() => {
            prompt.classList.remove('visible');
            prompt.classList.add('hidden');
        }, timeoutDuration);
    }, 100);
}

// Function to handle input focus
function handleFocus(event) {
    setTimeout(() => {
        document.body.classList.add(focusClass);
        event.target.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 100);
}

// Function to handle input blur
function handleBlur() {
  setTimeout(() => {
    document.body.classList.remove(focusClass);
  }, 100);
}

// Add event listeners to each input
inputs.forEach(input => {
  input.addEventListener('focus', handleFocus);
  input.addEventListener('blur', handleBlur);
});

// Scroll event
let lastScrollY = window.scrollY;
const scrollThreshold = 25;
window.addEventListener('scroll', () => {
    if (window.scrollY > lastScrollY && window.scrollY > scrollThreshold) {
        headerBlock.style.transform = 'translateY(-80px)';
        header.style.transform = 'translateY(-80px)';
        actionButton.style.transform = 'translateY(90px)';
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
    document.getElementById("custom-input").addEventListener("keypress", (e) => {
        if (e.key === "Enter") handleAdd("custom");
    });
    document.getElementById("sources-input").addEventListener("keypress", (e) => {
        if (e.key === "Enter") handleAdd("sources");
    });
    document.getElementById("blacklist-input").addEventListener("keypress", (e) => {
        if (e.key === "Enter") handleAdd("blacklist");
    });
    document.getElementById("whitelist-input").addEventListener("keypress", (e) => {
        if (e.key === "Enter") handleAdd("whitelist");
    });

    document.getElementById("custom-add").addEventListener("click", () => handleAdd("custom"));
    document.getElementById("sources-add").addEventListener("click", () => handleAdd("sources"));
    document.getElementById("blacklist-add").addEventListener("click", () => handleAdd("blacklist"));
    document.getElementById("whitelist-add").addEventListener("click", () => handleAdd("whitelist"));
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

// Initial load
window.onload = () => {
    adjustHeaderForMMRL();
    ["custom", "sources", "blacklist", "whitelist"].forEach(loadFile);
    attachAddButtonListeners();
    attachHelpButtonListeners();
};

// Function to check if running in MMRL
function adjustHeaderForMMRL() {
    if (typeof ksu !== 'undefined' && ksu.mmrl) {
        console.log("Running in MMRL");
        header.style.top = 'var(--window-inset-top)';
        headerBlock.style.display = 'block';
    }
}

// Execute shell commands
async function execCommand(command) {
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
