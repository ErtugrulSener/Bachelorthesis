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
    onChangeAuthenticationMethod(new_method)
}

function onChangeAuthenticationMethod(value)
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

function onIncreaseMethod()
{
    const method = (getMethod() + 1) % getDictLength(formFields)
    setMethod(method)
}

function onDecreaseMethod()
{
    const method = (getMethod() - 1 + getDictLength(formFields)) % getDictLength(formFields)
    setMethod(method)
}

function getDictLength(dct)
{
    return Object.keys(dct).length
}

$(function() {
    refreshForm()
});
