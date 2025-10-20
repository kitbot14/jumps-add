-- LocalScript (StarterPlayerScripts)
-- Interface Rayfield pour envoyer plusieurs fois JumpEvent avec valeur configurable

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Attend l'event JumpEvent
local ok, JumpEvent = pcall(function() return ReplicatedStorage:WaitForChild("JumpEvent", 5) end)
if not ok or not JumpEvent then
    warn("[AddJumpUI] JumpEvent introuvable dans ReplicatedStorage.")
    return
end

-- Paramètres par défaut
local amountValue = 2
local timesValue = 1
local MIN_INTERVAL = 0.05
local lastClick = 0

-- Création de la fenêtre Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Add Jump Controller",
    LoadingTitle = "Jump Manager",
    LoadingSubtitle = "by ChatGPT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "JumpManagerConfig",
        FileName = "JumpSettings"
    },
})

-- Création d'un onglet principal
local Tab = Window:CreateTab("Main", 4483362458) -- Icône Jump

-- Section configuration
Tab:CreateSection("Jump Settings")

-- Input pour Amount
local AmountInput = Tab:CreateInput({
    Name = "Amount (+)",
    CurrentValue = tostring(amountValue),
    PlaceholderText = "Valeur à envoyer (ex: 2)",
    RemoveTextAfterFocusLost = false,
    Flag = "AmountValue",
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            amountValue = math.clamp(math.floor(num), 1, 10000)
        else
            Rayfield:Notify({Title = "Erreur", Content = "Valeur invalide pour Amount", Duration = 2})
        end
    end,
})

-- Input pour le nombre de fois
local TimesInput = Tab:CreateInput({
    Name = "Nombre de fois",
    CurrentValue = tostring(timesValue),
    PlaceholderText = "Ex: 1",
    RemoveTextAfterFocusLost = false,
    Flag = "TimesValue",
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            timesValue = math.clamp(math.floor(num), 1, 10000)
        else
            Rayfield:Notify({Title = "Erreur", Content = "Valeur invalide pour Times", Duration = 2})
        end
    end,
})

-- Bouton principal
Tab:CreateButton({
    Name = "Envoyer JumpEvent",
    Callback = function()
        Rayfield:Notify({
            Title = "Envoi",
            Content = "Envoi de "..timesValue.." requêtes (+ "..amountValue..")",
            Duration = 2
        })
        coroutine.wrap(function()
            for i = 1, timesValue do
                local now = tick()
                if now - lastClick < MIN_INTERVAL then
                    task.wait(MIN_INTERVAL)
                end
                lastClick = tick()
                local success, err = pcall(function()
                    JumpEvent:FireServer(amountValue)
                end)
                if success then
                    print("[JumpEvent] Requête "..i.."/"..timesValue.." envoyée (+"..amountValue..")")
                else
                    warn("[JumpEvent] Erreur à l'envoi "..i..": "..tostring(err))
                    Rayfield:Notify({Title = "Erreur", Content = "Erreur à l'envoi "..i, Duration = 3})
                end
                task.wait(MIN_INTERVAL)
            end
        end)()
    end,
})

-- Section info
Tab:CreateSection("Infos")
Tab:CreateParagraph({Title = "Utilisation", Content = "Modifie 'Amount' et 'Nombre de fois', puis clique sur 'Envoyer JumpEvent'."})
