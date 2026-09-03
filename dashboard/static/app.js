const API = '';
let state = { tools: [], projectPath: '', mcpRunning: false, mcpPort: 8080, recentProjects: [] };
let browserPath = null;

// ── API Calls ───────────────────────────────────────────

async function fetchStatus() {
  try {
    const res = await fetch(`${API}/api/status`);
    const data = await res.json();
    state.tools = data.tools;
    state.mcpRunning = data.mcp_running;
    state.mcpPort = data.mcp_port;
    state.recentProjects = data.recent_projects || [];
    if (data.project_path && !state.projectPath) {
      state.projectPath = data.project_path;
      const short = data.project_path.split('/').slice(-2).join('/');
      document.getElementById('chosen-folder-text').textContent = short;
      document.getElementById('btn-choose-folder').classList.add('has-project');
    }
    if (data.graph && data.graph.file_count > 0) {
      updateStats(data.graph);
    }
    document.getElementById('version').textContent = `v${data.version}`;
    document.getElementById('telemetry-toggle').checked = data.telemetry === 'enabled';
    updateMcpIndicator();
    renderTools();
    renderRecentProjects();
  } catch (e) {
    console.error('Failed to fetch status:', e);
  }
}

async function fetchProjectInfo(path) {
  if (!path) return;
  try {
    const res = await fetch(`${API}/api/project${path}`);
    if (!res.ok) return;
    const data = await res.json();
    updateStats(data.graph);
  } catch (e) {
    console.error('Failed to fetch project info:', e);
  }
}

function updateStats(g) {
  document.getElementById('stat-files').textContent = g.file_count.toLocaleString();
  document.getElementById('stat-symbols').textContent = g.symbol_count.toLocaleString();
  document.getElementById('stat-nodes').textContent = g.node_count.toLocaleString();
  document.getElementById('stat-edges').textContent = g.edge_count.toLocaleString();
}

function updateMcpIndicator() {
  const dot = document.querySelector('.status-dot');
  const text = document.getElementById('status-text');
  if (state.mcpRunning) {
    dot.classList.add('active');
    text.textContent = `MCP server running on port ${state.mcpPort}`;
  } else {
    dot.classList.remove('active');
    text.textContent = 'MCP server not running';
  }
}

// ── Folder Browser ──────────────────────────────────────

async function openFolderBrowser() {
  document.getElementById('folder-modal').style.display = 'flex';
  await browseTo(null);
}

function closeFolderBrowser() {
  document.getElementById('folder-modal').style.display = 'none';
}

async function browseTo(path) {
  const url = path ? `${API}/api/browse/${path.replace(/^\//, '')}` : `${API}/api/browse`;
  try {
    const res = await fetch(url);
    const data = await res.json();
    browserPath = data.current;
    renderBreadcrumb(data.current);
    renderFolderList(data);
    updateModalSelection(data.current, data.is_project);
  } catch (e) {
    showToast('Cannot access this folder', 'error');
  }
}

function renderBreadcrumb(path) {
  const parts = path.split('/').filter(Boolean);
  const breadcrumb = document.getElementById('modal-breadcrumb');
  let html = `<span class="breadcrumb-item" onclick="browseTo('/')">~</span>`;
  let accumulated = '';
  for (const part of parts) {
    accumulated += '/' + part;
    const p = accumulated;
    html += `<span class="breadcrumb-sep">/</span>`;
    html += `<span class="breadcrumb-item" onclick="browseTo('${p}')">${part}</span>`;
  }
  breadcrumb.innerHTML = html;
}

function renderFolderList(data) {
  const list = document.getElementById('folder-list');
  let html = '';

  if (data.parent) {
    html += `
      <div class="folder-item folder-item-back" onclick="browseTo('${data.parent}')">
        <span class="folder-icon">&larr;</span>
        <span class="folder-name">..</span>
      </div>`;
  }

  for (const dir of data.dirs) {
    html += `
      <div class="folder-item ${dir.is_project ? 'is-project' : ''}" onclick="browseTo('${dir.path}')">
        <span class="folder-icon">${dir.is_project ? '📁' : '📂'}</span>
        <span class="folder-name">${dir.name}</span>
        ${dir.is_project ? '<span class="project-badge">project</span>' : ''}
      </div>`;
  }

  if (data.dirs.length === 0 && !data.parent) {
    html += `<div class="folder-item" style="color:var(--text-muted); cursor:default;">No accessible folders</div>`;
  }

  list.innerHTML = html;
}

function updateModalSelection(path, isProject) {
  const selectedEl = document.getElementById('modal-selected-path');
  const confirmBtn = document.getElementById('modal-confirm');
  const shortPath = path.replace(/^\/Users\/[^/]+/, '~');
  selectedEl.textContent = shortPath;
  confirmBtn.disabled = false;
  if (isProject) {
    selectedEl.style.color = 'var(--green)';
    confirmBtn.textContent = 'Select & Scan';
  } else {
    selectedEl.style.color = 'var(--text-secondary)';
    confirmBtn.textContent = 'Select Folder';
  }
}

async function confirmFolderSelection() {
  if (!browserPath) return;
  state.projectPath = browserPath;

  const shortPath = browserPath.split('/').slice(-2).join('/');
  document.getElementById('chosen-folder-text').textContent = shortPath;
  document.getElementById('btn-choose-folder').classList.add('has-project');

  closeFolderBrowser();

  await fetchProjectInfo(browserPath);

  const filesEl = document.getElementById('stat-files');
  if (filesEl.textContent === '--' || filesEl.textContent === '0') {
    showToast('Scanning project...', 'info');
    try {
      const res = await fetch(`${API}/api/scan`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ project_path: browserPath }),
      });
      const data = await res.json();
      if (data.ok && data.result) {
        updateStats(data.result);
        showToast(`Scanned: ${data.result.file_count} files, ${data.result.symbol_count} symbols`, 'success');
      } else {
        showToast('Scan complete', 'info');
      }
    } catch (e) {
      showToast('Scan failed: ' + e.message, 'error');
    }
  } else {
    showToast('Project loaded', 'success');
  }

  await fetchStatus();
}

// ── Tool Cards ──────────────────────────────────────────

function renderTools() {
  const grid = document.getElementById('tools-grid');
  const search = document.getElementById('tool-search').value.toLowerCase();
  const filtered = state.tools.filter(t => t.name.toLowerCase().includes(search));

  grid.innerHTML = filtered.map(tool => {
    const scope = tool.scope === 'home' ? 'Global' : tool.scope === 'cli' ? 'CLI' : 'Project';
    return `
      <div class="tool-card ${tool.enabled ? 'active' : ''}"
           style="--tool-color: ${tool.color}; --tool-glow: ${tool.color}33"
           data-tool-id="${tool.id}">
        <div class="tool-card-header">
          <div class="tool-info">
            <div class="tool-icon" style="background: ${tool.color}">${tool.icon}</div>
            <div>
              <div class="tool-name">${tool.name}</div>
              <div class="tool-status ${tool.enabled ? 'enabled' : ''}">${tool.enabled ? 'MCP Connected' : 'Disconnected'}</div>
            </div>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" ${tool.enabled ? 'checked' : ''}
                   onchange="toggleTool('${tool.id}', this.checked)">
            <span class="toggle-slider"></span>
          </label>
        </div>
        <div class="tool-card-footer">
          <span class="scope-badge scope-${tool.scope}">${scope}</span>
        </div>
      </div>
    `;
  }).join('');
}

function renderRecentProjects() {
  const container = document.getElementById('recent-projects');
  container.innerHTML = state.recentProjects.slice(0, 5).map(p => {
    const short = p.split('/').slice(-2).join('/');
    return `<div class="recent-project" onclick="selectProject('${p}')" title="${p}">~/${short}</div>`;
  }).join('');
}

async function selectProject(path) {
  state.projectPath = path;
  const short = path.split('/').slice(-2).join('/');
  document.getElementById('chosen-folder-text').textContent = short;
  document.getElementById('btn-choose-folder').classList.add('has-project');
  await fetchProjectInfo(path);
  await fetchStatus();
  showToast('Project loaded', 'success');
}

// ── Toggle MCP Config ──────────────────────────────────

async function toggleTool(toolId, enable) {
  if (!state.projectPath) {
    showToast('Choose a project folder first', 'error');
    openFolderBrowser();
    const checkbox = document.querySelector(`[data-tool-id="${toolId}"] input[type="checkbox"]`);
    if (checkbox) checkbox.checked = false;
    return;
  }

  const tool = state.tools.find(t => t.id === toolId);
  const toolName = tool ? tool.name : toolId;

  try {
    const res = await fetch(`${API}/api/toggle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        tool_id: toolId,
        enable: enable,
        project_path: state.projectPath,
      }),
    });
    const data = await res.json();
    if (data.ok) {
      showToast(data.message, 'success');
      await fetchStatus();
    } else {
      showToast(data.message || data.detail || 'Toggle failed', 'error');
      const checkbox = document.querySelector(`[data-tool-id="${toolId}"] input[type="checkbox"]`);
      if (checkbox) checkbox.checked = !enable;
    }
  } catch (e) {
    showToast('Failed to toggle: ' + e.message, 'error');
    const checkbox = document.querySelector(`[data-tool-id="${toolId}"] input[type="checkbox"]`);
    if (checkbox) checkbox.checked = !enable;
  }
}

// ── MCP Server Control ─────────────────────────────────

async function startMcp() {
  if (!state.projectPath) {
    showToast('Choose a project folder first', 'error');
    return;
  }
  try {
    const res = await fetch(`${API}/api/mcp/start`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ project_path: state.projectPath }),
    });
    const data = await res.json();
    if (data.ok) {
      showToast('MCP server started', 'success');
      await fetchStatus();
    } else {
      showToast(data.message || 'Failed to start MCP', 'error');
    }
  } catch (e) {
    showToast('Failed to start MCP: ' + e.message, 'error');
  }
}

async function stopMcp() {
  try {
    const res = await fetch(`${API}/api/mcp/stop`, { method: 'POST' });
    const data = await res.json();
    if (data.ok) {
      showToast('MCP server stopped', 'info');
      await fetchStatus();
    }
  } catch (e) {
    showToast('Failed to stop MCP: ' + e.message, 'error');
  }
}

// ── Settings ────────────────────────────────────────────

async function updateTelemetry(enabled) {
  try {
    await fetch(`${API}/api/settings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ telemetry: enabled }),
    });
    showToast(`Telemetry ${enabled ? 'enabled' : 'disabled'}`, 'info');
  } catch (e) {
    showToast('Failed to update setting', 'error');
  }
}

// ── Toast ───────────────────────────────────────────────

function showToast(message, type = 'info') {
  const container = document.getElementById('toast-container');
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.textContent = message;
  container.appendChild(toast);
  setTimeout(() => toast.remove(), 3500);
}

// ── Event Listeners ─────────────────────────────────────

document.getElementById('tool-search').addEventListener('input', renderTools);
document.getElementById('btn-choose-folder').addEventListener('click', openFolderBrowser);
document.getElementById('modal-close').addEventListener('click', closeFolderBrowser);
document.getElementById('modal-cancel').addEventListener('click', closeFolderBrowser);
document.getElementById('modal-confirm').addEventListener('click', confirmFolderSelection);
document.getElementById('telemetry-toggle').addEventListener('change', (e) => {
  updateTelemetry(e.target.checked);
});

document.getElementById('folder-modal').addEventListener('click', (e) => {
  if (e.target.id === 'folder-modal') closeFolderBrowser();
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') closeFolderBrowser();
});

// ── Init ────────────────────────────────────────────────

fetchStatus();
setInterval(fetchStatus, 5000);
