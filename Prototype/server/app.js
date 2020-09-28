const express = require('express')
const bodyParser = require('body-parser')
const JSEncrypt = require('node-jsencrypt')
const cors = require('cors')
const fs = require('fs')
const qrcode = require('qrcode')
const https = require('https');
const { Pool } = require('pg')
const { authenticator } = require('otplib');

const {
    generateAttestationOptions,
    verifyAttestationResponse,
    generateAssertionOptions,
    verifyAssertionResponse,
  } = require('@simplewebauthn/server');

const {
    ReasonPhrases,
    StatusCodes,
    getReasonPhrase,
    getStatusCode,
} = require('http-status-codes')

const connection = require('./scripts/connection.js')
const { apiSend, createSessionCookie, clearSessionCookie } = require('./scripts/api.js')
const { hashString } = require('./scripts/hashing.js')

const WEBAPP_ORIGIN = "localhost"
const WEBAPP_URL = "https://" + WEBAPP_ORIGIN + ":5500"
const SERVER_PORT = 3000
const PROJECT_NAME = "clsec"

const privateKey  = fs.readFileSync('../keys/ssl/server.key', 'utf8');
const certificate = fs.readFileSync('../keys/ssl/server.cert', 'utf8');
const sslCredentials = {key: privateKey, cert: certificate};

const app = express()

https.createServer(sslCredentials, app).listen(SERVER_PORT, () => {
    console.log('clsec started with port: ' + SERVER_PORT)
})

app.use(cors({credentials: true, origin: WEBAPP_URL}))

app.use(bodyParser.urlencoded({
    extended: true
}))
app.use(bodyParser.json())

app.use((req, res, next) => {
    res.setHeader("Access-Control-Allow-Origin", WEBAPP_URL)
    res.setHeader("Access-Control-Allow-Credentials", "true")
    res.setHeader("Access-Control-Allow-Methods", "GET,POST,PUT")
    res.setHeader("Access-Control-Allow-Headers", "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers")
    next()
})

const pool = new Pool(connection.getConnectionDetails())

app.post('/password/login', function (req, res) {
    const encrypted_username = req.body.username
    const encrypted_password = req.body.password

    const privkey = fs.readFileSync('../keys/rsa_1024_priv.pem', 'utf8')

    const decrypter = new JSEncrypt()
    decrypter.setPrivateKey(privkey)
    var username = decrypter.decrypt(encrypted_username)
    var password = decrypter.decrypt(encrypted_password)

    pool.query("SELECT username, password, salt FROM users WHERE username = $1::text", [username], (queryErr, queryRes) => {
        if (queryErr) throw queryErr

        if (queryRes.rows.length == 0)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED, "Username oder Passwort falsch")
            return
        }

        const database_password = queryRes.rows[0].password
        const database_salt = queryRes.rows[0].salt
        const success = database_password === hashString(password, database_salt)

        if (!success)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED, "Username oder Passwort falsch")
            return
        }

        createSessionCookie(req, res)
        apiSend(res, StatusCodes.OK)
    })
})

app.get('/password/create_password_hash', (req, res) => {
    const password_hash = hashString(req.query.password, req.query.salt)
    apiSend(res, StatusCodes.OK, password_hash)
})

app.post('/logout', (req, res) => {
    clearSessionCookie(req, res)
    res.redirect(WEBAPP_URL + '/index.html');
})

app.get('/get_public_key', (req, res) => {
    const pubkey = fs.readFileSync('../keys/rsa_1024_pub.pem', 'utf8')
    apiSend(res, StatusCodes.OK, pubkey)
})

function createTotpAuthenticationUrl(username,  totp_secret, req, res)
{
    const secret = totp_secret || authenticator.generateSecret();
    const otpauth = authenticator.keyuri(username, PROJECT_NAME, secret);
        
    qrcode.toDataURL(otpauth, (err, imageUrl) => {
        if (err) throw err;

        pool.query("UPDATE users SET totp_secret = $1::text WHERE username = $2::text AND totp_secret = null", [secret, username], (updateErr, updateRes) => {
            if (updateErr) throw updateErr;
        })

        apiSend(res, StatusCodes.OK, {'otpauth': otpauth, 'imageUrl': imageUrl, 'secret': secret})
    })
}

app.post('/totp/check_username', (req, res) => {
    const username = req.body.username

    if (!username)
    {
        apiSend(res, StatusCodes.UNAUTHORIZED, "Username oder Passwort falsch")
        return
    }

    pool.query("SELECT totp_secret, totp_activated FROM users WHERE username = $1::text", [username], (queryErr, queryRes) => {
        if (queryErr) throw queryErr

        if (queryRes.rows.length == 0)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED, "Username oder Passwort falsch")
            return
        }

        const totp_activated = queryRes.rows[0].totp_activated
        const totp_secret = queryRes.rows[0].totp_secret

        if (totp_activated === 1)
        {
            apiSend(res, StatusCodes.OK, "Success")
            return;
        }

        createTotpAuthenticationUrl(username, totp_secret, req, res)
    })
})

app.post('/totp/check_token', (req, res) => {
    const username = req.body.username
    const totp_token = req.body.totp_token

    if (!username || !totp_token)
    {
        apiSend(res, StatusCodes.UNAUTHORIZED)
        return
    }

    pool.query("SELECT totp_secret FROM users WHERE username = $1::text", [username], (queryErr, queryRes) => {
        if (queryErr) throw queryErr

        if (queryRes.rows.length == 0)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        const totp_secret = queryRes.rows[0].totp_secret

        if (!totp_secret)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return;
        }

        const isValid = authenticator.check(totp_token, totp_secret);

        if (!isValid)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED, "Invalid TOTP Code")
            return;
        }

        pool.query("UPDATE users SET totp_activated = 1 WHERE username = $1::text AND totp_activated = 0", [username], (updateErr, updateRes) => {
            if (updateErr) throw updateErr;
        })

        createSessionCookie(req, res)
        apiSend(res, StatusCodes.OK)
    })
})

app.get('/webauthn/generate-attestation-options', (req, res) => {
    const username = req.query.username

    pool.query("SELECT id, webauthn_private_key FROM users WHERE username = $1::text", [username], (queryErr, queryRes) => {
        if (queryErr) throw queryErr

        if (queryRes.rows.length == 0)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        if (queryRes.rows[0].webauthn_private_key)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        const options = generateAttestationOptions({
            rpName: PROJECT_NAME,
            rpId: WEBAPP_ORIGIN,
            userID: queryRes.rows[0].id,
            userName: username,
            userDisplayName: username,
            attestationType: 'none',
            authenticatorSelection: {
                requireResidentKey: false,
                userVerification: "discouraged",
            },
            extensions: {
                txAuthSimple: ""
            }
        });
    
        pool.query("UPDATE users SET webauthn_register_challenge = $1::text WHERE username = $2::text", [options.challenge, username], (updateErr, updateRes) => {
            if (updateErr) throw updateErr;
        })

        res.send(options)
    })
})

app.post('/webauthn/verify-attestation', (req, res) => {
    const username = req.body.username
    const attResp = req.body.attResp

    pool.query("SELECT webauthn_register_challenge, webauthn_private_key FROM users WHERE username = $1::text", [username], async (queryErr, queryRes) => {
        if (queryErr) throw queryErr

        if (queryRes.rows.length == 0)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        if (queryRes.rows[0].webauthn_private_key)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        const expectedChallenge = queryRes.rows[0].webauthn_register_challenge

        const verification = await verifyAttestationResponse({
                credential: attResp,
                expectedChallenge,
                expectedOrigin: WEBAPP_URL,
                expectedRPID: WEBAPP_ORIGIN,
            })

        const { verified, authenticatorInfo } = verification;
        const { base64PublicKey, base64CredentialID, counter } = authenticatorInfo;
        
        const Authenticator = {
            credentialID: base64CredentialID,
            publicKey: base64PublicKey,
            counter,
        };

        pool.query("UPDATE users SET webauthn_private_key = $1 WHERE username = $2::text", [Authenticator, username], (updateErr, updateRes) => {
            if (updateErr) throw updateErr;
        })

        res.send( { verified });
    })
})

app.get('/webauthn/generate-assertion-options', (req, res) => {
    const username = req.query.username

    pool.query("SELECT id, webauthn_private_key FROM users WHERE username = $1::text", [username], (queryErr, queryRes) => {
        if (queryErr) throw queryErr

        if (queryRes.rows.length == 0)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        if (!queryRes.rows[0].webauthn_private_key)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        const credentialID = queryRes.rows[0].webauthn_private_key.credentialID

        const options = generateAssertionOptions({
            extensions: {
                txAuthSimple: "",
            },
            allowedCredentialIDs: [credentialID],
          });
    
        pool.query("UPDATE users SET webauthn_login_challenge = $1::text WHERE username = $2::text", [options.challenge, username], (updateErr, updateRes) => {
            if (updateErr) throw updateErr;
        })

        res.send(options)
    })
})

app.post('/webauthn/verify-assertion', (req, res) => {
    const username = req.body.username
    const attResp = req.body.attResp

    pool.query("SELECT webauthn_login_challenge, webauthn_private_key FROM users WHERE username = $1::text", [username], async (queryErr, queryRes) => {
        if (queryErr) throw queryErr

        if (queryRes.rows.length == 0)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        if (!queryRes.rows[0].webauthn_private_key)
        {
            apiSend(res, StatusCodes.UNAUTHORIZED)
            return
        }

        const expectedChallenge = queryRes.rows[0].webauthn_login_challenge
        const webauthn_private_key = queryRes.rows[0].webauthn_private_key

        const verification = await verifyAssertionResponse({
                credential: attResp,
                expectedChallenge,
                expectedOrigin: WEBAPP_URL,
                expectedRPID: WEBAPP_ORIGIN,
                authenticator: webauthn_private_key
            })

        const { verified, _ } = verification;
        webauthn_private_key.counter += 1

        pool.query("UPDATE users SET webauthn_private_key = $1 WHERE username = $2::text", [webauthn_private_key, username], (updateErr, updateRes) => {
            if (updateErr) throw updateErr;
        })

        createSessionCookie(req, res)
        res.send( { verified });
    })
})