# GOLD# ⚡ XAUUSD AI Scalper Pro

A real-time Gold (XAUUSD) scalping dashboard powered by AI intelligence — live charts, multi-timeframe signal matrix, Entry/TP/SL levels, and deep AI market analysis.

---

## 🚀 Deploy to GitHub + Vercel (Step-by-Step)

### Step 1 — Push to GitHub

```bash
# In your terminal, inside this project folder:
git init
git add .
git commit -m "Initial: XAUUSD AI Scalper Pro"

# Create a new repo on github.com, then:
git remote add origin https://github.com/YOUR_USERNAME/xauusd-ai-scalper.git
git branch -M main
git push -u origin main
```

---

### Step 2 — Connect to Vercel

1. Go to **[vercel.com](https://vercel.com)** → Sign in with GitHub
2. Click **"Add New Project"**
3. Import your `xauusd-ai-scalper` GitHub repo
4. Vercel auto-detects the config — click **Deploy**

---

### Step 3 — Add Your Anthropic API Key (CRITICAL)

The AI Deep Scan button requires your Anthropic API key, stored **securely server-side**:

1. In Vercel dashboard → your project → **Settings → Environment Variables**
2. Add:
   - **Name:** `ANTHROPIC_API_KEY`
   - **Value:** `sk-ant-...` (your key from [console.anthropic.com](https://console.anthropic.com))
   - **Environment:** Production, Preview, Development ✓
3. Click **Save**
4. Go to **Deployments → Redeploy** to apply

> ⚠️ **NEVER** put your API key in the HTML or commit it to GitHub. The `/api/ai-scan.js` serverless function keeps it safe.

---

### Step 4 — Get Your API Key

1. Visit [console.anthropic.com](https://console.anthropic.com)
2. Go to **API Keys** → **Create Key**
3. Copy and paste into Vercel env vars (Step 3)

---

## 📁 Project Structure

```
xauusd-ai-scalper/
├── public/
│   └── index.html        # Main app (charts, signals, UI)
├── api/
│   └── ai-scan.js        # Vercel serverless function (secure API proxy)
├── vercel.json           # Routing & build config
├── package.json
├── .gitignore            # Keeps .env and node_modules out of git
└── README.md
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 📊 Live Candlestick Chart | Real-time OHLC with EMA, Bollinger Bands |
| 🎯 Entry / TP / SL Levels | Drawn on chart per timeframe |
| 📡 8-Timeframe Matrix | M1 to W1 signal overview |
| 🤖 AI Deep Scan | Claude-powered market analysis |
| 📈 RSI / MACD / Volume | Live oscillator sub-charts |
| ⚡ Live Price Feed | Simulated tick engine (plug in real broker API) |
| 🔔 Signal Alerts | Rolling tape with live alerts |

---

## 🔌 Connecting a Real Price Feed

To use real live prices, replace the `updatePrice()` function in `index.html` with a WebSocket connection:

```js
// Example: connecting to a broker WebSocket
const ws = new WebSocket('wss://your-broker-feed.com/xauusd');
ws.onmessage = (event) => {
  const tick = JSON.parse(event.data);
  currentPrice = tick.bid;
  updatePriceDisplay();
  redrawAll();
};
```

Compatible with: **FXCM, OANDA, IC Markets, Forex.com** WebSocket APIs.

---

## ⚠️ Disclaimer

This tool is for **educational and analytical purposes only**. It does not constitute financial advice. Forex and Gold trading involves substantial risk of loss. Always use proper risk management.
