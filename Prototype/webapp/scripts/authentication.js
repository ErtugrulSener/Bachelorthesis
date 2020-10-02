window.clsec = (function (clsec) {
    let cached_pubkey = false;

    const MIN_USERNAME_LENGTH = 8;
    const MIN_PASSWORD_LENGTH = 8;

    const SERVER_URL = "https://localhost:3000/"
    
    clsec.verifiedSuccessfully = function ()
    {
        window.location.replace("/secret_panel.html");
    }
    
    getPublicKey = function()
    {
        if (cached_pubkey)
            return cached_pubkey;
    
        let publicKey = ""
        const xhttp = new XMLHttpRequest();
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

    encryptWithPublicKey = function(text)
    {
        const encrypter = new JSEncrypt();
        const pubkey = getPublicKey();
        encrypter.setPublicKey(pubkey);
        const encrypted = encrypter.encrypt(text);
    
        return encrypted
    }
    
    loginWithUserpass = function()
    {
        const userFieldValue = document.getElementById("username").value
        const passFieldValue = document.getElementById("password").value
    
        if (userFieldValue.length < MIN_USERNAME_LENGTH || passFieldValue.length < MIN_PASSWORD_LENGTH)
            return;
    
        const username = encryptWithPublicKey(userFieldValue)
        const password = encryptWithPublicKey(passFieldValue)
        const xhttp = new XMLHttpRequest();
    
        xhttp.onreadystatechange = function() {
            if (this.readyState == 4)
            {
                if (this.status == 200)
                {
                    clsec.verifiedSuccessfully()
                }
                else
                {
                    console.log(this.responseText)
                }
            }
        };
    
        xhttp.open("POST", SERVER_URL + "password/login");
        xhttp.withCredentials = true;
        xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xhttp.send(JSON.stringify({"username": username, "password": password}));
    }

    loginWithTotp = function()
    {
        const totp_token = clsec.getTotpToken()
        const userFieldValue = document.getElementById("totp_username").value
        
        if (userFieldValue.length < MIN_USERNAME_LENGTH)
            return;
    
        const username = userFieldValue
        const xhttp = new XMLHttpRequest();

        if (document.getElementById("totp_secret").style.display === "none")
        {
            xhttp.onreadystatechange = function() {
                if (this.readyState == 4)
                {
                    if (this.status == 200)
                    {
                        clsec.verifiedSuccessfully()
                    }
                    else
                    {
                        console.log(this.responseText)
                    }
                }
            };
      
            xhttp.open("POST", SERVER_URL + "totp/check_token");
            xhttp.withCredentials = true;
            xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
            xhttp.send(JSON.stringify({"username": username, "totp_token": totp_token}));
        }
        else
        {
            xhttp.onreadystatechange = function() {
                if (this.readyState == 4)
                {
                    if (this.status == 200)
                    {
                        const res = JSON.parse(this.responseText)

                        if (res.msg === "Success")
                        {
                            clsec.hideObj("totp_qr_image")
                            clsec.hideObj("totp_secret")
                        }
                        else
                        {
                            const totp_qr_image = document.getElementById("totp_qr_image")
                            const totp_secret = document.getElementById("totp_secret")
            
                            totp_qr_image.src = res.msg.imageUrl;
                            clsec.showObj("totp_qr_image")
            
                            totp_secret.innerHTML = res.msg.secret
                            totp_secret.href = res.msg.otpauth
                            clsec.showObj("totp_secret")
                        }
    
                        clsec.addClass("totp_token", "form-control");
                        clsec.showObj("totp_token")
    
                        clsec.removeClass("flexbox_totp", "flexbox_totp")
                    }
                    else
                    {
                        console.log(this.responseText)
                    }
                }
            };
      
            xhttp.open("POST", SERVER_URL + "totp/check_username");
            xhttp.withCredentials = true;
            xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
            xhttp.send(JSON.stringify({"username": username}));
        }
    }

    loginWithWebAuthentication = async function()
    {
        const username = document.getElementById("webauthn_username").value
    
        if (username.length < MIN_USERNAME_LENGTH)
            return;

        const resp = await fetch(SERVER_URL + 'webauthn/generate-assertion-options?username='+username)
        const asseResp = await SimpleWebAuthnBrowser.startAssertion(await resp.json())
        
        const verificationResp = await fetch(SERVER_URL + 'webauthn/verify-assertion', {
            method: 'POST',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({"username": username, "attResp": asseResp}),
        });
        
        const verificationJSON = await verificationResp.json();
        
        if (verificationJSON && verificationJSON.verified)
        {
            clsec.verifiedSuccessfully()
        }
        else
        {
            console.log('Error', verificationJSON)
        }
    };

    const AUTH_FUNCTIONS = {
        0: loginWithUserpass,
        1: loginWithTotp,
        2: loginWithWebAuthentication,
    }

    clsec.login = function()
    {
        const method = clsec.getMethod()
        const func = AUTH_FUNCTIONS[method]

        if (func)
            func()
    }

    $(function() {
        $('#webauthn_register_button').click(async () => {
            const username = document.getElementById("webauthn_username").value

            if (username.length < MIN_USERNAME_LENGTH)
                return;

            const resp = await fetch(SERVER_URL + 'webauthn/generate-attestation-options?username='+username)
            const attResp = await SimpleWebAuthnBrowser.startAttestation(await resp.json())

            const verificationResp = await fetch(SERVER_URL + 'webauthn/verify-attestation', {
                method: 'POST',
                credentials: 'include',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({"username": username, "attResp": attResp}),
            });
        
            const verificationJSON = await verificationResp.json();
        
            if (verificationJSON && verificationJSON.verified)
            {
                console.log('Success!');
            }
            else
            {
                console.log('Error', verificationJSON)
            }
        })
    })

    return clsec;
}(window.clsec || {}));