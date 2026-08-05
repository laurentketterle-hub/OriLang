// options.js — Chrome extension options page logic
// Demonstrates chrome.storage API usage (the OriLang way: type-safe, clean)

const defaults = {
  apiUrl: 'https://api.example.com/v1',
  theme: 'auto',
  maxResults: 10
};

function showStatus(msg, type) {
  const el = document.getElementById('statusMsg');
  el.textContent = msg;
  el.className = 'status ' + type;
  el.style.display = 'block';
  setTimeout(() => { el.style.display = 'none'; }, 3000);
}

function loadOptions() {
  chrome.storage.sync.get(defaults, (items) => {
    document.getElementById('apiUrl').value = items.apiUrl;
    document.getElementById('theme').value = items.theme;
    document.getElementById('maxResults').value = items.maxResults;
  });
}

function saveOptions() {
  const settings = {
    apiUrl: document.getElementById('apiUrl').value,
    theme: document.getElementById('theme').value,
    maxResults: parseInt(document.getElementById('maxResults').value, 10) || 10
  };
  chrome.storage.sync.set(settings, () => {
    if (chrome.runtime.lastError) {
      showStatus('Error: ' + chrome.runtime.lastError.message, 'error');
    } else {
      showStatus('Settings saved successfully!', 'success');
    }
  });
}

document.addEventListener('DOMContentLoaded', loadOptions);
document.getElementById('save').addEventListener('click', saveOptions);
