local sqlite3 = require('lsqlite3')

-- Datenbankverbindung erstellen
local db = sqlite3.open('users.db')

-- Tabelle erstellen, wenn sie nicht existiert
db:exec[[
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT
);
]]

-- Registrierungsfunktion
RegisterCommand('register', function(source, args, rawCommand)
    local username = args[1]
    local password = args[2]

    if not username or not password then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'SYSTEM', 'Bitte benutze: /register <Benutzername> <Passwort>' }
        })
        return
    end

    local stmt = db:prepare("INSERT INTO users (username, password) VALUES (?, ?)")
    stmt:bind_values(username, password)

    if stmt:execute() then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'SYSTEM', 'Benutzer erfolgreich registriert!' }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'SYSTEM', 'Fehler bei der Registrierung! Benutzername könnte bereits existieren.' }
        })
    end

    stmt:finalize()
end, false)

-- Anmeldungsfunktion
RegisterCommand('login', function(source, args, rawCommand)
    local username = args[1]
    local password = args[2]

    if not username or not password then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'SYSTEM', 'Bitte benutze: /login <Benutzername> <Passwort>' }
        })
        return
    end

    for row in db:nrows("SELECT * FROM users WHERE username = '" .. username .. "' AND password = '" .. password .. "'") do
        if row.username == username then
            TriggerClientEvent('chat:addMessage', source, {
                args = { 'SYSTEM', 'Willkommen, ' .. username .. '!' }
            })
            return
        end
    end

    TriggerClientEvent('chat:addMessage', source, {
        args = { 'SYSTEM', 'Ungültiger Benutzername oder Passwort.' }
    })
end, false)
