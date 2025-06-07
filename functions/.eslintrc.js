module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    tsconfigRootDir: __dirname,
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignora arquivos compilados
  ],
  plugins: ["@typescript-eslint", "import"],
  rules: {
    "quotes": ["error", "double"], // Força aspas duplas
    "max-len": ["error", { "code": 120 }], // Aumenta limite de linha para 120 caracteres
    "object-curly-spacing": ["error", "always"], // Remove espaços em { }
    "indent": ["error", 2], // Indentação com 2 espaços
    "require-jsdoc": "off", // Desativa exigência de JSDoc
    "no-trailing-spaces": "error", // Mantém verificação de espaços extras
    "eol-last": ["error", "always"], // Exige nova linha no final do arquivo
  },
};
