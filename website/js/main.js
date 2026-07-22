const API = 'http://localhost:8000/api/v1';

document.addEventListener('DOMContentLoaded', () => {
  // Nav scroll
  const nav = document.querySelector('.nav');
  window.addEventListener('scroll', () => nav.classList.toggle('scrolled', window.scrollY > 50));

  // Theme
  const themeBtn = document.querySelector('.theme-toggle');
  themeBtn?.addEventListener('click', () => {
    const html = document.documentElement;
    const next = html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
  });
  const saved = localStorage.getItem('theme');
  if (saved) document.documentElement.setAttribute('data-theme', saved);

  // Mobile menu
  document.querySelector('.mobile-toggle')?.addEventListener('click', () => {
    document.querySelector('.nav-links')?.classList.toggle('open');
    document.body.classList.toggle('mobile-nav-open');
  });
  document.querySelectorAll('.nav-links a').forEach(a =>
    a.addEventListener('click', () => {
      document.querySelector('.nav-links')?.classList.remove('open');
      document.body.classList.remove('mobile-nav-open');
    })
  );

  // Scroll reveal
  const observer = new IntersectionObserver(entries =>
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); }),
    { threshold: .15 }
  );
  document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));

  // Number counters
  const countObserver = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (!e.isIntersecting) return;
      const el = e.target;
      const target = parseFloat(el.getAttribute('data-count'));
      const isFloat = target % 1 !== 0;
      const duration = 1500;
      const start = performance.now();
      const step = (now) => {
        const pct = Math.min((now - start) / duration, 1);
        const eased = 1 - Math.pow(1 - pct, 3);
        const current = target * eased;
        el.textContent = isFloat ? current.toFixed(1) : Math.floor(current).toLocaleString();
        if (pct < 1) requestAnimationFrame(step);
        else el.textContent = isFloat ? target.toFixed(1) : Math.floor(target).toLocaleString();
      };
      requestAnimationFrame(step);
      countObserver.unobserve(el);
    });
  });
  document.querySelectorAll('.hero-stats [data-count]').forEach(el => countObserver.observe(el));

  // Init all async data
  loadIndices();
  loadStocks();
  loadPortfolio();
  setupAIChat();
});

async function api(path) {
  try {
    const res = await fetch(API + path);
    const json = await res.json();
    return json.success ? json.data : [];
  } catch { return []; }
}

async function loadIndices() {
  const data = await api('/markets/indices');
  const rows = document.querySelectorAll('.phone-row');
  if (!rows.length) return;
  data.slice(0, 3).forEach((d, i) => {
    if (!rows[i]) return;
    const up = d.change_percent >= 0;
    const sym = rows[i].querySelector('.sym');
    const price = rows[i].querySelectorAll('.num');
    if (sym) sym.textContent = d.symbol;
    if (price[0]) price[0].textContent = d.last_value?.toLocaleString();
    if (price[1]) {
      price[1].textContent = `${up ? '+' : ''}${d.change_percent?.toFixed(2)}%`;
      price[1].className = `num ${up ? 'up' : 'dn'}`;
    }
  });
}

async function loadStocks(sector) {
  let data;
  if (sector === 'gainers') data = await api('/markets/gainers?limit=8');
  else if (sector === 'losers') data = await api('/markets/losers?limit=8');
  else data = await api('/markets/stocks' + (sector ? '?sector='+encodeURIComponent(sector) : ''));
  const tbody = document.getElementById('stock-body');
  if (!tbody) return;
  tbody.innerHTML = (Array.isArray(data) ? data : []).map(s => `<tr>
    <td style="font-weight:600;">${s.symbol}</td>
    <td style="color:var(--muted);font-size:13px;">${s.name}</td>
    <td class="num">₹${(s.last_price||0).toFixed(2)}</td>
    <td><span class="${(s.change||0)>=0?'price-up':'price-down'} num">${(s.change||0)>=0?'+':''}${(s.change||0).toFixed(2)}</span></td>
    <td><span class="${(s.change_percent||0)>=0?'price-up':'price-down'} num">${(s.change_percent||0)>=0?'+':''}${(s.change_percent||0).toFixed(2)}%</span></td>
    <td class="num" style="color:var(--muted);">${((s.volume||0)/1e6).toFixed(1)}M</td>
  </tr>`).join('');
}

function setupMarketTabs() {
  const container = document.querySelector('.market-controls');
  if (!container) return;
  container.addEventListener('click', e => {
    const tab = e.target.closest('.market-tab');
    if (!tab) return;
    document.querySelectorAll('.market-tab').forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    const filter = tab.getAttribute('data-filter');
    loadStocks(filter);
  });
  setupMarketTabs = () => {};
}

async function loadPortfolio() {
  const summary = await api('/portfolio/summary');
  const holdings = await api('/portfolio/holdings');
  const cards = document.querySelectorAll('.stat-card .stat-value');
  const changes = document.querySelectorAll('.stat-card .stat-change');
  if (summary) {
    if (cards[0]) cards[0].textContent = '₹' + (summary.total_invested||0).toLocaleString();
    if (cards[1]) cards[1].textContent = '₹' + (summary.current_value||0).toLocaleString();
    if (cards[2]) cards[2].textContent = (summary.today_pl||0) >= 0 ? '+₹' + (summary.today_pl||0).toLocaleString() : '-₹' + Math.abs(summary.today_pl||0).toLocaleString();
    if (changes[1]) changes[1].textContent = '+' + (summary.returns_percent||0).toFixed(1) + '% overall';
    if (changes[2]) {
      changes[2].textContent = ((summary.today_pl_percent||0) >= 0 ? '+' : '') + (summary.today_pl_percent||0).toFixed(2) + '% today';
      changes[2].className = 'stat-change ' + ((summary.today_pl||0) >= 0 ? 'pos' : '');
    }
    // Update cards[2] color
    if (cards[2]) cards[2].style.color = (summary.today_pl||0) >= 0 ? 'var(--green)' : 'var(--red)';
  }
  const tbody = document.getElementById('holdings-body');
  if (!tbody) return;
  tbody.innerHTML = (Array.isArray(holdings) ? holdings : []).map(h => {
    const up = (h.pl||0) >= 0;
    return `<tr>
      <td><div style="font-weight:600;">${h.symbol}</div><div style="font-size:12px;color:var(--muted);">${h.name}</div></td>
      <td class="num" style="color:var(--muted);">${h.quantity}</td>
      <td class="num" style="color:var(--muted);">${Math.round(h.avg_price||0)}</td>
      <td class="num">${(h.ltp||0).toFixed(0)}</td>
      <td class="num">₹${(h.value||0).toLocaleString()}</td>
      <td class="num" style="color:${up?'var(--green)':'var(--red)'};">${up?'+':''}${(h.pl_percent||0).toFixed(2)}%</td>
    </tr>`;
  }).join('');
}

let chatHistory = [];
function setupAIChat() {
  const input = document.getElementById('chat-input');
  const send = document.getElementById('chat-send');
  const messages = document.getElementById('chat-messages');
  const clear = document.getElementById('chat-clear');
  if (!input || !messages) return;

  const sendMsg = async () => {
    const text = input.value.trim();
    if (!text) return;
    input.value = '';
    appendMsg('user', text);
    appendMsg('bot', 'Thinking...', true);
    try {
      const res = await fetch(API + '/ai/chat', {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({message: text, history: chatHistory}),
      });
      const json = await res.json();
      const reply = json.data?.response || 'Sorry, try again.';
      chatHistory.push({role:'user', content:text}, {role:'assistant', content:reply});
      const thinking = messages.querySelector('.thinking');
      if (thinking) thinking.remove();
      appendMsg('bot', reply);
    } catch {
      const thinking = messages.querySelector('.thinking');
      if (thinking) thinking.remove();
      appendMsg('bot', 'Error: Could not reach FinSwitch AI. Make sure the backend is running.');
    }
  };

  const appendMsg = (role, content, isThinking) => {
    const div = document.createElement('div');
    div.className = `msg ${role}` + (isThinking ? ' thinking' : '');
    div.innerHTML = role === 'bot' ? `<div class="sender">FinSwitch AI</div>${content}` : content;
    messages.appendChild(div);
    messages.scrollTop = messages.scrollHeight;
  };

  input.addEventListener('keydown', e => { if (e.key === 'Enter') sendMsg(); });
  send?.addEventListener('click', sendMsg);
  clear?.addEventListener('click', () => {
    messages.innerHTML = '<div class="msg bot"><div class="sender">FinSwitch AI</div>Hi! I\'m your financial intelligence assistant. Ask me about any stock or market trend.</div>';
    chatHistory = [];
  });

  setupAIChat = () => {};
  setupMarketTabs();
}
