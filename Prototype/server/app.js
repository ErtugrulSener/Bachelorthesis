const express = require('express')
const cookieSession = require('cookie-session')
const bodyParser = require('body-parser');
const JSEncrypt = require('node-jsencrypt');
const cors = require('cors')
const fs = require('fs')

const PORT = 3000

const connection_helper = require('./scripts/connection.js');

const { Pool, Client } = require('pg')
const { apiSend } = require('./scripts/api.js');
const { hashString } = require('./scripts/hashing.js');
const { v4: uuidv4 } = require('uuid');
const Cookies = require('cookies')

const app = express()
const server = app.listen(PORT, () => console.log('clsec started with port: ' + PORT));

const GracefulShutdownManager = require('@moebius/http-graceful-shutdown').GracefulShutdownManager;
const shutdown_manager = new GracefulShutdownManager(server);

const {
    ReasonPhrases,
    StatusCodes,
    getReasonPhrase,
    getStatusCode,
} = require('http-status-codes');

app.use(cors({credentials: true, origin: 'http://127.0.0.1:5500'}));

app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());

app.use(cookieSession({
    name: 'user_sid',
    keys: ["LkwfS6QLbEKX858T", "JLWKjmEbAfRnRssH", "VHm8XrsWfdyDHchU"],
    maxAge: 24 * 60 * 60 * 1000,
    httpOnly: false
}));

app.use((req, res, next) => {
    //res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Credentials", "true");
    res.setHeader("Access-Control-Allow-Methods", "GET,POST,PUT,POST");
    // res.setHeader("Access-Control-Allow-Headers", "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers");
    next();
});

const pool = new Pool(connection_helper.getConnectionDetails())

app.post('/login', function (req, res) {
    const encrypted_username = req.body.username;
    const encrypted_password = req.body.password;

    const privkey = fs.readFileSync('keys/rsa_1024_priv.pem', 'utf8')

    const decrypt = new JSEncrypt();
    decrypt.setPrivateKey(privkey);
    var username = decrypt.decrypt(encrypted_username);
    var password = decrypt.decrypt(encrypted_password);

    pool.query("SELECT username, password, salt FROM users WHERE username = $1::text", [username], (queryErr, queryRes) => {
        if (queryErr) throw queryErr;

        if (queryRes.rows.length == 0)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED, "Username oder Passwort falsch")
            return;
        }

        (async () => {
            const database_password = queryRes.rows[0].password
            const database_salt = queryRes.rows[0].salt
            const success = database_password === hashString(password, database_salt)

            if (!success)
            {
                apiSend(res, StatusCodes.UNAUTHORIZED, "Username oder Passwort falsch")
                return;
            }

            let cookieHandler = new Cookies(req, res)
            cookieHandler.set('user_sid', uuidv4())
            apiSend(res, StatusCodes.OK)
        })();
    })
})

app.get('/logout', (req, res) => {
    let cookieHandler = new Cookies(req, res)

    if (cookieHandler.get("user_sid")) {
        cookieHandler.set('user_sid', '', {overwrite: true})
    }

    res.send()
});

app.get('/get_public_key', (req, res) => {
    const pubkey = fs.readFileSync('keys/rsa_1024_pub.pem', 'utf8')
    apiSend(res, StatusCodes.OK, pubkey)
});

process.on('exit', () => {
    shutdown_manager.terminate(() => {
        console.log('Server is gracefully terminated');
    });
});
