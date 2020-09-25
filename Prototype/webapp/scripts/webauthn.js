import { 
    solveRegistrationChallenge,
    solveLoginChallenge
} from './utils/webauthn/client/index.js';

window.clsec = (function (webauthn) {
    const MIN_USERNAME_LENGTH = 8

    webauthn.loginWithWebAuthentication = (async () =>
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

        console.log(challenge)
        const credentials = await solveRegistrationChallenge(challenge);
        // console.log(credentials)

        /*const { loggedIn } = await fetch(
            'http://${clsec.SERVER_URL}/webauthn/register',
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
        }*/

        console.log("Registration successful")
    });

    return webauthn;
}(window.clsec || {}));
