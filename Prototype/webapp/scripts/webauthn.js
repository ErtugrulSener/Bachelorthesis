import { 
    solveRegistrationChallenge,
    solveLoginChallenge
} from './utils/webauthn/client/index.js';

window.clsec = (function (webauthn) {
    const MIN_USERNAME_LENGTH = 8

    webauthn.loginWithWebAuthentication = async function()
    {
        const username = document.getElementById("webauthn_username").value

        if (username.length < MIN_USERNAME_LENGTH)
            return;

        const challenge = await fetch(clsec.SERVER_URL + 'webauthn/request-login', {
            method: 'POST',
            headers: {
                'content-type': 'Application/Json'
            },
            body: JSON.stringify({ "username": username })
        })
        .then(response => response.json());
        console.log(challenge)

        const credentials = await solveLoginChallenge(challenge);
        const { loggedIn } = await fetch(clsec.SERVER_URL + 'webauthn/login', 
            {
                method: 'POST',
                headers: {
                    'content-type': 'Application/Json'
                },
                body: JSON.stringify(credentials)
            }
        ).then(response => response.json());
    
        if (!loggedIn) {
            console.log("Login failed")
            return;
        }

        console.log("Login successful")
    };

    $(function() {
        $('#webauthn_register_button').click(function() {
            (async () =>
            {
                const username = document.getElementById("webauthn_username").value

                if (username.length < MIN_USERNAME_LENGTH)
                    return;
        
                const challenge = await fetch(clsec.SERVER_URL + 'webauthn/request-register', {
                    method: 'POST',
                    headers: {
                        'content-type': 'Application/Json'
                    },
                    body: JSON.stringify({ "username": username })
                })
                .then(response => response.json());
    
                const credentials = await solveRegistrationChallenge(challenge);
        
                const { loggedIn } = await fetch(clsec.SERVER_URL + 'webauthn/register',
                    {
                        method: 'POST',
                        headers: {
                            'content-type': 'Application/Json'
                        },
                        body: JSON.stringify(credentials)
                    }
                ).then(response => response.json());
        
                if (!loggedIn) {
                    console.log("Registration failed")
                    return;
                }
        
                console.log("Registration successful")
            })()
        })
    });

    return webauthn;
}(window.clsec || {}));
