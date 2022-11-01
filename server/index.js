const express = require("express");
const mongoose = require("mongoose");

const PORT = process.env.PORN || 4000;

const app = express();

app.listen(PORT, "0.0.0.0");
