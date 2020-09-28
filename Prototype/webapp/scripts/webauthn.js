const { startAttestation, startAssertion } = SimpleWebAuthnBrowser;

window.clsec = (function (webauthn) {
    webauthn.loginWithWebAuthentication = async function()
    {
        const username = document.getElementById("webauthn_username").value
    
        if (username.length < clsec.MIN_USERNAME_LENGTH)
            return;

        const resp = await fetch(clsec.SERVER_URL + 'webauthn/generate-assertion-options?username='+username)
        const asseResp = await startAssertion(await resp.json())
        
        const verificationResp = await fetch(clsec.SERVER_URL + 'webauthn/verify-assertion', {
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

    $(function() {
        $('#webauthn_register_button').click(async () => {
            const username = document.getElementById("webauthn_username").value
    
            if (username.length < clsec.MIN_USERNAME_LENGTH)
                return;

            const resp = await fetch(clsec.SERVER_URL + 'webauthn/generate-attestation-options?username='+username)
            const attResp = await startAttestation(await resp.json())

            const verificationResp = await fetch(clsec.SERVER_URL + 'webauthn/verify-attestation', {
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
    });

    return webauthn;
}(window.clsec || {}));
