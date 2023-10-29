const fs = require("fs");
require("dotenv").config();
const { Pool } = require("pg");

const pool = new Pool({
  user: "andrew",
  host: "leaner-mage-3654.g95.cockroachlabs.cloud",
  database: "defaultdb",
  password: "BNQKF-PTVDCzwHiF5lnWtw",
  port: 26257,
  ssl: {
    rejectUnauthorized: false,
  },
});

module.exports = {
  query: (text, params) => pool.query(text, params),
};
