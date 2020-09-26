window.clsec = (function (clsec) {
    const METHODS = {
        USERPASS: 0,
        TOTP: 1,
        WEBAUTHN: 2,
        CLIENTLESS: 3,
    }

    let formFields = {
        0: ["flexbox_userpass"],
        1: ["flexbox_totp"],
        2: ["flexbox_webauthn", "webauthn_register_button"],
    }

    clsec.getMethod = function()
    {
        const method = Number(document.getElementById("method").value)
        return method
    }

    clsec.getTotpSecret = function()
    {
        const totp_secret = document.getElementById("totp_secret").innerHTML
        return totp_secret
    }

    clsec.getTotpToken = function()
    {
        const totp_token = document.getElementById("totp_token").value
        return totp_token
    }

    clsec.getSessionCookie = function()
    {
        const session_cookie = Cookies.get('user_sid');
        return session_cookie
    }

    function setMethod(new_method)
    {
        let methodDropdownMenu = document.getElementById("method");
        methodDropdownMenu.value = new_method;
        clsec.onChangeAuthenticationMethod(new_method)
    }

    clsec.onChangeAuthenticationMethod = function(value)
    {
        refreshForm(value)
    }

    function refreshForm(method = METHODS.USERPASS)
    {
        for (const [_, elementsToShow] of Object.entries(formFields))
        {
            for (const elementName of elementsToShow)
            {
                if (formFields[method].includes(elementName))
                    clsec.showObj(elementName)
                else
                    clsec.hideObj(elementName)
            }
        }
    }

    clsec.hideObj = function(name)
    {
        document.getElementById(name).style.display = "none"
    }

    clsec.showObj = function(name)
    {
        document.getElementById(name).style.display = "inline-block"
    }

    clsec.addClass = function(name, class_name)
    {
        document.getElementById(name).classList.add(class_name)
    }

    clsec.removeClass = function(name, class_name)
    {
        document.getElementById(name).classList.remove(class_name)
    }

    clsec.onIncreaseMethod = function()
    {
        const method = (clsec.getMethod() + 1) % getDictLength(formFields)
        setMethod(method)
    }

    clsec.onDecreaseMethod = function()
    {
        const method = (clsec.getMethod() - 1 + getDictLength(formFields)) % getDictLength(formFields)
        setMethod(method)
    }

    function getDictLength(dct)
    {
        return Object.keys(dct).length
    }

    $(function() {
        const form = document.getElementById("main_form");

        if (form)
        {
            $('#main_form').submit(function(event) {
                event.preventDefault()
                return false
            })

            $('#submit').click(function() {
                clsec.login()
            })

            refreshForm()
        }
    });

    return clsec;
}(window.clsec || {}));