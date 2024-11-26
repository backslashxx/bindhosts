const basePath = "/data/adb/bindhosts";

const filePaths = {
    custom: `${basePath}/custom.txt`,
    sources: `${basePath}/sources.txt`,
    blacklist: `${basePath}/blacklist.txt`,
    whitelist: `${basePath}/whitelist.txt`,
};

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
        await updateStatusFromModuleProp();
    } catch (error) {
        console.error(`Failed to load ${fileType} file: ${error}`);
    }
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

// Function to show the prompt with a success or error message
function showPrompt(message, isSuccess = true) {
    const prompt = document.getElementById('prompt');
    prompt.textContent = message;
    prompt.classList.toggle('error', !isSuccess);
    if (window.promptTimeout) {
        clearTimeout(window.promptTimeout);
    }
    setTimeout(() => {
        prompt.classList.add('visible');
        prompt.classList.remove('hidden');
        window.promptTimeout = setTimeout(() => {
            prompt.classList.remove('visible');
            prompt.classList.add('hidden');
        }, 5000);
    }, 500);
}

// Attach the function to the action button
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

// Initial load
window.onload = () => {
    ["custom", "sources", "blacklist", "whitelist"].forEach(loadFile);
    attachAddButtonListeners();
    attachHelpButtonListeners();
};

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