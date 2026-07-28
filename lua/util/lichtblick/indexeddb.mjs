const port = Number.parseInt(process.argv[2] ?? '9222', 10);
const operation = process.argv[3] ?? 'read';

if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error(`Invalid Chrome DevTools port: ${process.argv[2]}`);
}

const response = await fetch(`http://127.0.0.1:${port}/json/list`, {
  signal: AbortSignal.timeout(3000),
});
if (!response.ok) {
  throw new Error(`Chrome DevTools endpoint returned HTTP ${response.status}`);
}

const targets = await response.json();
const target = targets.find((item) => item.type === 'page' && item.url?.startsWith('package://'))
  ?? targets.find((item) => item.type === 'page');
if (!target?.webSocketDebuggerUrl) {
  throw new Error('No Lichtblick renderer target was found');
}

const readExpression = String.raw`(async () => {
  const databases = await indexedDB.databases();
  const databaseInfo = databases.find(({ name }) => name?.endsWith("lichtblick-layouts"));
  if (!databaseInfo?.name) {
    throw new Error("Lichtblick layout database was not found");
  }

  const database = await new Promise((resolve, reject) => {
    const request = indexedDB.open(databaseInfo.name);
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
  });
  try {
    const records = await new Promise((resolve, reject) => {
      const transaction = database.transaction("layouts", "readonly");
      const request = transaction.objectStore("layouts").getAll();
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve(request.result);
    });
    return { database: databaseInfo.name, records };
  } finally {
    database.close();
  }
})()`;

let expression = readExpression;
if (operation === 'write-script') {
  const chunks = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk);
  }
  const input = JSON.parse(Buffer.concat(chunks).toString('utf8'));
  for (const key of ['database', 'namespace', 'layoutId', 'scriptId', 'sourceCode']) {
    if (typeof input[key] !== 'string') {
      throw new Error(`Invalid write-script input: ${key}`);
    }
  }

  expression = `(async () => {
    const input = ${JSON.stringify(input)};
    if (!input.database.endsWith("lichtblick-layouts")) {
      throw new Error("Refusing to write an unexpected IndexedDB database");
    }
    const database = await new Promise((resolve, reject) => {
      const request = indexedDB.open(input.database);
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve(request.result);
    });
    try {
      await new Promise((resolve, reject) => {
        const transaction = database.transaction("layouts", "readwrite");
        const store = transaction.objectStore("layouts");
        const request = store.get([input.namespace, input.layoutId]);
        transaction.onerror = () => reject(transaction.error);
        transaction.onabort = () => reject(transaction.error ?? new Error("IndexedDB transaction aborted"));
        transaction.oncomplete = () => resolve();
        request.onerror = () => reject(request.error);
        request.onsuccess = () => {
          try {
            const record = request.result;
            if (!record?.layout) {
              throw new Error("Lichtblick layout record no longer exists");
            }
            const layout = record.layout;
            const currentData = layout.working?.data ?? layout.baseline?.data ?? layout.data ?? layout.state;
            if (!currentData?.userNodes?.[input.scriptId]
              || typeof currentData.userNodes[input.scriptId].sourceCode !== "string") {
              throw new Error("Lichtblick user script no longer exists");
            }

            const nextData = structuredClone(currentData);
            nextData.userNodes[input.scriptId].sourceCode = input.sourceCode;
            layout.working = {
              data: nextData,
              savedAt: new Date().toISOString(),
            };
            store.put(record);
          } catch (error) {
            transaction.abort();
            reject(error);
          }
        };
      });
      setTimeout(() => location.reload(), 0);
      return { updated: true };
    } finally {
      database.close();
    }
  })()`;
} else if (operation !== 'read') {
  throw new Error(`Unsupported operation: ${operation}`);
}

const result = await new Promise((resolve, reject) => {
  const socket = new WebSocket(target.webSocketDebuggerUrl);
  const timeout = setTimeout(() => {
    socket.close();
    reject(new Error('Timed out while reading Lichtblick IndexedDB'));
  }, 10000);

  socket.addEventListener('open', () => {
    socket.send(JSON.stringify({
      id: 1,
      method: 'Runtime.evaluate',
      params: {
        expression,
        awaitPromise: true,
        returnByValue: true,
      },
    }));
  });
  socket.addEventListener('message', (event) => {
    const message = JSON.parse(event.data);
    if (message.id !== 1) {
      return;
    }

    clearTimeout(timeout);
    socket.close();
    if (message.result?.exceptionDetails) {
      reject(new Error(message.result.exceptionDetails.exception?.description ?? 'IndexedDB evaluation failed'));
      return;
    }
    resolve(message.result?.result?.value);
  });
  socket.addEventListener('error', () => {
    clearTimeout(timeout);
    reject(new Error('Could not connect to the Lichtblick renderer'));
  });
});

if (operation === 'read' && (!result || !Array.isArray(result.records))) {
  throw new Error('Lichtblick returned an invalid IndexedDB response');
}
if (operation === 'write-script' && result?.updated !== true) {
  throw new Error('Lichtblick did not confirm the IndexedDB update');
}

process.stdout.write(JSON.stringify(result));
