import { solveRegistrationChallenge, solveLoginChallenge } from '@webauthn/client';

// const loginButton = document.getElementById('login');
const registerButton = document.getElementById('register');

registerButton.onclick = async () => {
    const challenge = await fetch('https://${clsec.SERVER_URL}/request-register', {
        method: 'POST',
        headers: {
            'content-type': 'Application/Json'
        },
        body: JSON.stringify({ id: 'uuid', email: 'test@clsec.de' })
    })
        .then(response => response.json());
    const credentials = await solveRegistrationChallenge(challenge);

    const { loggedIn } = await fetch(
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
    }

    console.log("Registration successful")
};
