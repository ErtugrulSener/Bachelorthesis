const crypto = require('crypto');

exports.hashString = function (password, salt) {
    const PEPPER = "8}f_ab!VyqeJujX6";

    let hash = crypto.createHmac('sha512', salt);
    hash.update(PEPPER + password);

    return hash.digest('hex');
};