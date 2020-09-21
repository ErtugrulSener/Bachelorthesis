
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
        2: [],
        3: [],
    }

    function getMethod()
    {
        const method = Number(document.getElementById("method").value)
        return method
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
                    showObj(elementName)
                else
                    hideObj(elementName)
            }
        }
    }

    function hideObj(name)
    {
        document.getElementById(name).style.display = "none"
    }

    function showObj(name)
    {
        document.getElementById(name).style.display = "block"
    }

    form_handler.onIncreaseMethod = function()
    {
        const method = (getMethod() + 1) % getDictLength(formFields)
        setMethod(method)
    }

    form_handler.onDecreaseMethod = function()
    {
        const method = (getMethod() - 1 + getDictLength(formFields)) % getDictLength(formFields)
        setMethod(method)
    }

    function getDictLength(dct)
    {
        return Object.keys(dct).length
    }

    $(function() {
        const form = document.getElementById( "main_form" );

        form.addEventListener( "submit", function ( event ) {
            event.preventDefault();
        });

        refreshForm()
    });

    return form_handler;
}(window.clsec || {}));