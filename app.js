const express = require('express');
const pgp = require('pg-promise')();

require('dotenv').config();

const app = express();
const port = process.env.APP_PORT;
const db = pgp(`postgres://postgres:${process.env.POSTGRES_PASSWORD}@db:5432/${process.env.POSTGRES_DB}`);

app.set('view engine', 'pug');

app.get('/', (_, res) => {
  db.many('SELECT * FROM teams').then((data) => {
    res.render('index', {
      title: 'Teams',
      teams: data
    });
  });
});

app.listen(port, () => console.log(`Listening at http://localhost:${port}`));
