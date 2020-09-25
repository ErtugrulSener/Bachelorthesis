window.clsec = (function (form_handler) {
    const METHODS = {
        USERPASS: 0,
        TOTP: 1,
        WEBAUTHN: 2,
        CLIENTLESS: 3,
    }

    let formFields = {
        0: ["flexbox_userpass"],
        1: ["flexbox_totp"],
        2: ["flexbox_webauthn"],
        3: [],
    }

    form_handler.getMethod = function()
    {
        const method = Number(document.getElementById("method").value)
        return method
    }

    form_handler.getTotpSecret = function()
    {
        const totp_secret = document.getElementById("totp_secret").innerHTML
        return totp_secret
    }

    form_handler.getTotpToken = function()
    {
        const totp_token = document.getElementById("totp_token").value
        return totp_token
    }

    form_handler.getSessionCookie = function()
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

    form_handler.onChangeAuthenticationMethod = function(value)
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
                    form_handler.showObj(elementName)
                else
                    form_handler.hideObj(elementName)
            }
        }
    }

    form_handler.hideObj = function(name)
    {
        document.getElementById(name).style.display = "none"
    }

    form_handler.showObj = function(name)
    {
        document.getElementById(name).style.display = "block"
    }

    form_handler.addClass = function(name, class_name)
    {
        document.getElementById(name).classList.add(class_name)
    }

    form_handler.onIncreaseMethod = function()
    {
        const method = (form_handler.getMethod() + 1) % getDictLength(formFields)
        setMethod(method)
    }

    form_handler.onDecreaseMethod = function()
    {
        const method = (form_handler.getMethod() - 1 + getDictLength(formFields)) % getDictLength(formFields)
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
            form.addEventListener("submit", function (event) {
                event.preventDefault();
            });

            refreshForm()
        }
    });

    return form_handler;
}(window.clsec || {}));