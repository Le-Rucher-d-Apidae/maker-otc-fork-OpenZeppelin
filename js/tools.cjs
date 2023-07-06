const Fs = require('fs');

const createDirAndSubdirsIfNotExists = (_dirPath) => {
  try {
    if (!Fs.existsSync(_dirPath)) {
      Fs.mkdirSync(_dirPath, { recursive: true });
    }
  } catch (err) {
    console.error(`createDirAndSubdirsIfNotExists: err= ${err}}`);
  }
} // createDirAndSubdirsIfNotExists


exports.createDirAndSubdirsIfNotExists = createDirAndSubdirsIfNotExists;