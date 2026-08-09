const fs = require('fs');
const config = require('./config');
const ProxyManager = require('./modules/proxyManager');
const registerBot = require('./modules/registerBot');
const CollectorBot = require('./modules/collectorBot');
const { sleep, getIndex, writeIndex } = require('./modules/utils');

const LOG_FILE = 'bot.log';
function log(msg) { const line = `[${new Date().toISOString()}] ${msg}\n`; fs.appendFileSync(LOG_FILE, line); }
function randomString(length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < length; i++) result += chars.charAt(Math.floor(Math.random() * chars.length));
  return result;
}

const proxyManager = new ProxyManager();
let currentIndex = getIndex(config.indexFile);
let activeBots = 0;
const botInstances = [];

async function mainLoop() {
  while (true) {
    try {
      const proxy = proxyManager.getAvailableProxy();
      if (!proxy || activeBots >= config.maxBots) {
        await sleep(1000);
        continue;
      }
      if (!proxyManager.acquireSlot()) {
        await sleep(500);
        continue;
      }
      currentIndex++;
      writeIndex(config.indexFile);
      const username = randomString(
        Math.floor(Math.random() * (config.maxUsernameLength - config.minUsernameLength + 1)) +
          config.minUsernameLength
      );
      const password = randomString(config.passwordLength);
      log(`Регистрация ${username}`);
      let registered = false;
      for (let attempt = 1; attempt <= config.registerAttempts; attempt++) {
        try {
          await registerBot(username, password);
          registered = true;
          break;
        } catch (e) {
          log(`Попытка ${attempt} регистрации ${username} не удалась: ${e.message}`);
          if (attempt < config.registerAttempts) await sleep(5000);
        }
      }
      if (!registered) {
        log(`Не удалось зарегистрировать ${username}, освобождаем слот`);
        proxyManager.releaseSlot();
        continue;
      }

      // ========== ДОБАВЛЕНА ПАУЗА 5 СЕКУНД ПОСЛЕ РЕГИСТРАЦИИ ==========
      await sleep(5000);

      activeBots++;
      const collector = new CollectorBot(username, password, (result) => {
        proxyManager.releaseSlot();
        activeBots--;
        const idx = botInstances.indexOf(collector);
        if (idx !== -1) botInstances.splice(idx, 1);
        log(`Бот ${username} завершён, активных: ${activeBots}`);
      });
      botInstances.push(collector);

      // Увеличенная задержка между циклами до 10 секунд
      await sleep(10000);
    } catch (e) {
      log(`Ошибка в цикле: ${e.message}`);
      await sleep(1000);
    }
  }
}

mainLoop().catch((e) => log(`Фатальная ошибка: ${e.message}`));
