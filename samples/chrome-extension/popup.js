// popup.js — Chrome extension popup page logic
document.getElementById('action').addEventListener('click', () => {
  chrome.storage.sync.get(['apiUrl', 'theme', 'maxResults'], (items) => {
    document.getElementById('status').textContent =
      'Connected to: ' + (items.apiUrl || 'default') +
      ' (theme: ' + (items.theme || 'auto') +
      ', limit: ' + (items.maxResults || 10) + ')';
  });
});
