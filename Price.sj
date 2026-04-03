// api/price.js
// Vercel Serverless Function — proxies Twelve Data API (keeps key server-side)
// Endpoints used:
//   GET /api/price?type=quote          → latest XAUUSD price
//   GET /api/price?type=candles&tf=M5  → OHLCV candle history
//   GET /api/price?type=indicators&tf=M5 → RSI + MACD

const TF_MAP = {
  M1:  '1min',
  M5:  '5min',
  M15: '15min',
  M30: '30min',
  H1:  '1h',
  H4:  '4h',
  D1:  '1day',
  W1:  '1week',
};

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const API_KEY = process.env.TWELVE_DATA_API_KEY;
  if (!API_KEY) {
    return res.status(500).json({ error: 'TWELVE_DATA_API_KEY not set in Vercel environment variables.' });
  }

  const { type, tf = 'M5' } = req.query;
  const interval = TF_MAP[tf] || '5min';
  const symbol = 'XAU/USD';
  const base = 'https://api.twelvedata.com';

  try {
    // ── QUOTE: latest bid/ask/price ─────────────────────────────────────────
    if (type === 'quote') {
      const url = `${base}/quote?symbol=${encodeURIComponent(symbol)}&apikey=${API_KEY}`;
      const r = await fetch(url);
      const data = await r.json();

      if (data.status === 'error' || data.code) {
        return res.status(400).json({ error: data.message || 'Twelve Data error' });
      }

      return res.status(200).json({
        price:  parseFloat(data.close),
        open:   parseFloat(data.open),
        high:   parseFloat(data.high),
        low:    parseFloat(data.low),
        change: parseFloat(data.change),
        pct:    parseFloat(data.percent_change),
        volume: parseInt(data.volume || 0),
        ts:     data.datetime,
      });
    }

    // ── CANDLES: OHLCV history ───────────────────────────────────────────────
    if (type === 'candles') {
      const url = `${base}/time_series?symbol=${encodeURIComponent(symbol)}&interval=${interval}&outputsize=80&apikey=${API_KEY}`;
      const r = await fetch(url);
      const data = await r.json();

      if (data.status === 'error' || data.code) {
        return res.status(400).json({ error: data.message || 'Twelve Data error' });
      }

      // Reverse so oldest → newest
      const candles = (data.values || []).reverse().map(v => ({
        o: parseFloat(v.open),
        h: parseFloat(v.high),
        l: parseFloat(v.low),
        c: parseFloat(v.close),
        v: parseInt(v.volume || 0),
        t: v.datetime,
      }));

      return res.status(200).json({ candles });
    }

    // ── INDICATORS: RSI + MACD ───────────────────────────────────────────────
    if (type === 'indicators') {
      const [rsiRes, macdRes] = await Promise.all([
        fetch(`${base}/rsi?symbol=${encodeURIComponent(symbol)}&interval=${interval}&time_period=14&outputsize=80&apikey=${API_KEY}`),
        fetch(`${base}/macd?symbol=${encodeURIComponent(symbol)}&interval=${interval}&outputsize=80&apikey=${API_KEY}`),
      ]);

      const [rsiData, macdData] = await Promise.all([rsiRes.json(), macdRes.json()]);

      const rsi = (rsiData.values || []).reverse().map(v => parseFloat(v.rsi));
      const macd = (macdData.values || []).reverse().map(v => parseFloat(v.macd));

      return res.status(200).json({ rsi, macd });
    }

    return res.status(400).json({ error: 'Invalid type. Use: quote | candles | indicators' });

  } catch (err) {
    console.error('Price API error:', err);
    return res.status(500).json({ error: 'Server error: ' + err.message });
  }
}
