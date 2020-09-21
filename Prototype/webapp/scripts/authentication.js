
window.clsec = (function (authentication) {
    let cached_pubkey = false;

    const MIN_USERNAME_LENGTH = 8;
    const MIN_PASSWORD_LENGTH = 8;

    authentication.SERVER_URL = "http://127.0.0.1:3000/"
    
    authentication.createHash = function(text)
    {
        let sha512 = new jsSHA('SHA-512', 'TEXT');
        sha512.update(password);
        const sha512_password = sha512.getHash("HEX");
    
        return sha512_password;
    }
    
    authentication.getPublicKey = function()
    {
        if (cached_pubkey)
            return cached_pubkey;
    
        let publicKey = ""
        let xhttp = new XMLHttpRequest();
        xhttp.open("GET", authentication.SERVER_URL + "get_public_key", false);
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
    
    authentication.encryptWithPublicKey = function(text)
    {
        let encrypter = new JSEncrypt();
        const pubkey = authentication.getPublicKey();
        encrypter.setPublicKey(pubkey);
        const encrypted = encrypter.encrypt(text);
    
        return encrypted
    }
    
    authentication.loginWithUserpass = function()
    {
        let userFieldValue = document.getElementById("username").value
        let passFieldValue = document.getElementById("password").value
    
        if (userFieldValue.length < MIN_USERNAME_LENGTH || passFieldValue.length < MIN_PASSWORD_LENGTH)
            return;
    
        let username = authentication.encryptWithPublicKey(userFieldValue)
        let password = authentication.encryptWithPublicKey(passFieldValue)
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
    
        xhttp.open("POST", authentication.SERVER_URL + "login");
        xhttp.withCredentials = true;
        xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xhttp.send(JSON.stringify({"username": username, "password": password}));
    }
    
    $(function() {
        $("#submit").click(function(event) {
            event.preventDefault();
            authentication.loginWithUserpass()
        });
    });

    return authentication;
}(window.clsec || {}));