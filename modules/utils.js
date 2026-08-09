const fs = require('fs');
const sleep = ms => new Promise(r => setTimeout(r, ms));
const readLines = file => { try { return fs.readFileSync(file, 'utf8').split('\n').filter(l => l.trim()); } catch(e) { return []; } };
const writeIndex = file => { const idx = parseInt(fs.readFileSync(file, 'utf8')) || 0; fs.writeFileSync(file, String(idx + 1)); return idx + 1; };
const getIndex = file => { try { return parseInt(fs.readFileSync(file, 'utf8')) || 0; } catch(e) { fs.writeFileSync(file, '1'); return 1; } };
module.exports = { sleep, readLines, writeIndex, getIndex };
