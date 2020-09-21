let cached_pubkey = false;

const MIN_USERNAME_LENGTH = 8;
const MIN_PASSWORD_LENGTH = 8;
const SERVER_URL = "http://127.0.0.1:3000/"

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
    xhttp.open("GET", SERVER_URL + "get_public_key", false);
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
    let userFieldValue = document.getElementById("username").value
    let passFieldValue = document.getElementById("password").value

    if (userFieldValue.length < MIN_USERNAME_LENGTH || passFieldValue.length < MIN_PASSWORD_LENGTH)
        return;

    let username = encryptWithPublicKey(userFieldValue)
    let password = encryptWithPublicKey(passFieldValue)
    let xhttp = new XMLHttpRequest();

    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200)
    {
        window.location.replace("/webapp/secret_panel.html");
      }
      else
      {
          console.log(this.responseText)
      }
    };

    xhttp.open("POST", SERVER_URL + "login");
    xhttp.withCredentials = true;
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhttp.send(JSON.stringify({"username": username, "password": password}));
}

$("#submit").click(function(event) {
    event.preventDefault();
    loginWithUserpass()
});