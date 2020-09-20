const { getReasonPhrase } = require("http-status-codes");

module.exports = {
    apiSend: function(res, status_code, status_message) {
        res.status(status_code).send(JSON.stringify({
            status: status_code,
            msg: status_message || getReasonPhrase(status_code)
        }));
    }
}