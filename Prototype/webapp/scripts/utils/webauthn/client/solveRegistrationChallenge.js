import { publicKeyCredentialToJSON } from './utils.js';

const registrationChallengeToPublicKey = credentialsChallengeRequest => {
    return {
        ...credentialsChallengeRequest,
        challenge: Unibabel.base64ToBuffer(
            credentialsChallengeRequest.challenge
        ),
        user: {
            ...credentialsChallengeRequest.user,
            id: Unibabel.base64ToBuffer(credentialsChallengeRequest.user.id),
        },
    };
};

export const solveRegistrationChallenge = async credentialsChallengeRequest => {
    const publicKey = registrationChallengeToPublicKey(
        credentialsChallengeRequest
    );
    const credentials = await navigator.credentials.create({
        publicKey,
    });

    return publicKeyCredentialToJSON(credentials);
};