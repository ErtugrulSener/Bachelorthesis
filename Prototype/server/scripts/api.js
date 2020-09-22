const { getReasonPhrase } = require("http-status-codes");
const { v4: uuidv4 } = require('uuid')
const Cookies = require('cookies')

exports.apiSend = function(res, status_code, status_message) {
    res.status(status_code).send(JSON.stringify({
        status: status_code,
        msg: status_message || getReasonPhrase(status_code)
    }));
}

exports.createSessionCookie = function(req, res) {
    let cookieHandler = new Cookies(req, res)
    cookieHandler.set('user_sid', uuidv4(), {httpOnly: false})
}

exports.clearSessionCookie = function(req, res) {
    let cookieHandler = new Cookies(req, res)

    if (cookieHandler.get("user_sid")) {
        cookieHandler.set('user_sid', '', {httpOnly: false, overwrite: true})
    }
}