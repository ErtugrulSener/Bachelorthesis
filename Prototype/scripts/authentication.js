function createHash(text)
{
    let sha512 = new jsSHA('SHA-512', 'TEXT');
    sha512.update(password);
    const sha512_password = sha512.getHash("HEX");

    return sha512_password;
}

function getPublicKey()
{
    let publicKey = ""
    let rawFile = new XMLHttpRequest();
    rawFile.open("GET", "http://127.0.0.1:5500/keys/rsa_1024_pub.pem", false);
    rawFile.onreadystatechange = function ()
    {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status == 0)
            {
                publicKey = rawFile.responseText
            }
        }
    }
    rawFile.send(null);

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