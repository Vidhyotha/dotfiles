// Routes links that would open a regular Chromium tab out to the system
// default browser (via a native messaging host that calls xdg-open).
//
// Scope: only tabs freshly CREATED in windows of type "normal". This means:
//  - a link clicked inside an --app web app window (which Chromium opens as a
//    new normal-window tab) gets bounced to Firefox;
//  - the web app window itself, and popup windows (OAuth login flows), stay
//    in Chromium;
//  - typing a URL into an existing Chromium tab is left alone.

const HOST = 'com.omarchy.link_router';

// Tabs we created-and-are-watching until their real URL is known.
const pending = new Map(); // tabId -> true

function isWebUrl(url) {
  return typeof url === 'string' &&
    (url.startsWith('http://') || url.startsWith('https://'));
}

function isTransient(url) {
  // URLs a brand-new tab passes through before its real destination commits.
  return !url || url === 'about:blank';
}

async function route(tabId, url) {
  pending.delete(tabId);
  try {
    await chrome.runtime.sendNativeMessage(HOST, { url });
  } catch (e) {
    // Native host missing/broken: leave the tab alone so the link still works.
    console.error('link-router: native host failed, keeping tab', e);
    return;
  }
  try {
    await chrome.tabs.remove(tabId);
  } catch (e) {
    // Tab already gone — fine.
  }
}

async function inspect(tab) {
  const url = tab.pendingUrl || tab.url;
  if (isTransient(url)) return; // keep watching
  if (!isWebUrl(url)) {
    // chrome://newtab, chrome://extensions, etc. — a deliberate Chromium tab.
    pending.delete(tab.id);
    return;
  }
  let win;
  try {
    win = await chrome.windows.get(tab.windowId);
  } catch (e) {
    pending.delete(tab.id);
    return;
  }
  if (win.type !== 'normal') {
    // App window or popup (OAuth etc.) — must stay in Chromium.
    pending.delete(tab.id);
    return;
  }
  route(tab.id, url);
}

chrome.tabs.onCreated.addListener((tab) => {
  pending.set(tab.id, true);
  inspect(tab);
});

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (pending.has(tabId) && (changeInfo.url || changeInfo.status)) {
    inspect(tab);
  }
});

chrome.tabs.onRemoved.addListener((tabId) => pending.delete(tabId));
