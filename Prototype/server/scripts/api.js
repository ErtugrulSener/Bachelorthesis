const { getReasonPhrase } = require("http-status-codes");
const { v4: uuidv4 } = require('uuid')

let setCookieOptions = {
    maxAge: 1000 * 60 * 60 * 24,
    httpOnly: false,
    secure: true,
}

exports.apiSend = function(res, status_code, status_message) {
    res.status(status_code).send(JSON.stringify({
        status: status_code,
        msg: status_message || getReasonPhrase(status_code)
    }));
}

exports.createSessionCookie = function(req, res) {
    res.cookie('user_sid', uuidv4(), setCookieOptions)
}

exports.clearSessionCookie = function(req, res) {
    res.clearCookie('user_sid')
}