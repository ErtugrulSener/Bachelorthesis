let cached_pubkey = false;

function createHash(text)
{
    let sha512 = new jsSHA('SHA-512', 'TEXT');
    sha512.update(password);
    const sha512_password = sha512.getHash("HEX");

    return sha512_password;
}

function getPublicKey()
{
    if (cached_pubkey)
        return cached_pubkey;

    let publicKey = ""
    let xhttp = new XMLHttpRequest();
    xhttp.open("GET", "http://127.0.0.1:3000/get_public_key", false);
    xhttp.onreadystatechange = function ()
    {
        if (xhttp.readyState === 4 && xhttp.status == 200)
        {
			const response = JSON.parse(this.responseText);
			publicKey = response.msg
        }
    }
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhttp.send();

    cached_pubkey = publicKey
    return publicKey;
}

function encryptWithPublicKey(text)
{
    let encrypter = new JSEncrypt();
    const pubkey = getPublicKey();
    encrypter.setPublicKey(pubkey);
    const encrypted = encrypter.encrypt(text);

    return encrypted
}

function loginWithUserpass()
{
    let username = encryptWithPublicKey(document.getElementById("username").value)
    let password = encryptWithPublicKey(document.getElementById("password").value)
    let xhttp = new XMLHttpRequest();

    xhttp.onreadystatechange = function() {
      if (this.readyState == 4) {
        console.log(this.responseText);
      }
    };

    xhttp.open("POST", "http://127.0.0.1:3000/login");
    xhttp.withCredentials = true;
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhttp.send(JSON.stringify({"username": username, "password": password}));
}