# Jae's Library Documentation

Jae's LIB is a Roblox UI library based on the Orion Library style. It provides themed windows, tabs, controls, configuration profiles, search, a command palette, and built-in hub management tools

## Loading

```lua
local OrionLib = loadstring(game:HttpGet("YOUR_LIBRARY_URL"))()
```

The library requires a Roblox environment that supports the APIs used by the hub, including GUI instances, `HttpService`, and configuration file functions when persistence is enabled

## Creating a Window

```lua
local Window = OrionLib:MakeWindow({
    Name = "My Hub",
    ConfigFolder = "MyHub",
    SaveConfig = true,
    PersistUI = true,
    IntroEnabled = false,
    ShowIcon = true,
    Icon = "rbxassetid://8834748103",
    DashboardEnabled = true,
    Dashboard = {
        Name = "Home",
        Title = "Welcome",
        Content = "Choose a feature to begin."
    }
})
```

### Window options

| Option | Type | Default | Description |
|---|---|---:|---|
| `Name` | string | `Orion Library` | Window title. |
| `ConfigFolder` | string | window name | Folder used for configuration files. |
| `SaveConfig` | boolean | `false` | Enables saved control values. |
| `PersistUI` | boolean | `true` | Saves window layout and UI preferences. |
| `IntroEnabled` | boolean | `true` | Shows the intro animation. |
| `IntroText` | string | `Orion Library` | Intro title. |
| `IntroIcon` | string | default asset | Intro image. |
| `ShowIcon` | boolean | `false` | Displays an icon in the title bar. |
| `Icon` | string | default asset | Window icon. |
| `Background` | string or nil | `nil` | Background image asset. |
| `BackgroundTransparency` | number | `0.4` | Background image transparency. |
| `DashboardEnabled` | boolean | `true` | Adds the built-in Home dashboard. |
| `Dashboard` | table | `nil` | Custom dashboard settings. |
| `CloseCallback` | function | empty function | Called when the window is hidden. |

## Tabs

```lua
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home"
})
```

Tab options:

- `Name`: tab label.
- `Icon`: Lucide icon name or Roblox asset ID.
- `PremiumOnly`: replaces the tab contents with a Premium Only message.

Tabs can be selected from the sidebar, the command palette, or the built-in Tools tab.

## Controls

### Label

```lua
MainTab:AddLabel("Status: ready")
```

### Paragraph

```lua
MainTab:AddParagraph(
    "Information",
    "This text can contain a longer description."
)
```

### Button

```lua
MainTab:AddButton({
    Name = "Run action",
    Icon = "play",
    Favorite = true,
    Callback = function()
        print("Action executed")
    end
})
```

Button options:

- `Name`: visible button label.
- `Icon`: icon or asset ID.
- `Favorite`: adds the action to Favorites when true.
- `Callback`: function executed on click.

The returned button object supports:

```lua
local Action = MainTab:AddButton({
    Name = "Action",
    Callback = function() end
})

Action:Set("Updated action")
Action:SetFavorite(true)
```

### Toggle

```lua
local Toggle = MainTab:AddToggle({
    Name = "Enabled",
    Default = false,
    Flag = "Enabled",
    Save = true,
    Callback = function(Value)
        print(Value)
    end
})

Toggle:Set(true)
```

### Slider

```lua
local Slider = MainTab:AddSlider({
    Name = "Walk speed",
    Min = 16,
    Max = 100,
    Increment = 1,
    Default = 16,
    ValueName = "studs",
    Flag = "WalkSpeed",
    Save = true,
    Callback = function(Value)
        print(Value)
    end
})

Slider:Set(32)
```

### Dropdown

```lua
local Dropdown = MainTab:AddDropdown({
    Name = "Mode",
    Options = {"Safe", "Fast", "Custom"},
    Default = "Safe",
    Flag = "Mode",
    Save = true,
    Callback = function(Value)
        print(Value)
    end
})

Dropdown:Set("Fast")
Dropdown:Refresh({"Safe", "Fast", "Custom", "Experimental"}, true)
```

### Keybind

```lua
local Bind = MainTab:AddBind({
    Name = "Toggle menu",
    Default = Enum.KeyCode.RightShift,
    Hold = false,
    Flag = "MenuBind",
    Save = true,
    Callback = function()
        print("Bind pressed")
    end
})
```

The returned bind supports editing and removal:

```lua
Bind:Set(Enum.KeyCode.Insert)
Bind:Remove()
```

Keybinds registered with a `Flag` or `Name` are available through `OrionLib.Binds`.

### Textbox

```lua
local Textbox = MainTab:AddTextbox({
    Name = "Player name",
    Default = "",
    TextDisappear = false,
    Flag = "PlayerName",
    Save = true,
    Callback = function(Value)
        print(Value)
    end
})

Textbox:Set("Player")
```

### Colorpicker

```lua
local Colorpicker = MainTab:AddColorpicker({
    Name = "Accent color",
    Default = Color3.fromRGB(88, 101, 242),
    Flag = "AccentColor",
    Save = true,
    Callback = function(Color)
        print(Color)
    end
})

Colorpicker:Set(Color3.fromRGB(70, 200, 120))
```

## Built-in Features

### Search

The top bar search field filters visible controls across all tabs. Search matches labels, button text, textbox text, and other visible UI text.

### Command Palette

Open the command palette with the top-bar button or `Ctrl+K`.

The palette provides:

- Navigation to every tab.
- Save profile.
- Load profile.

### Home Dashboard

The Home tab includes:

- Hub title and description.
- Active profile textbox.
- Save preset.
- Load preset.
- Quick access information.

Disable it with:

```lua
DashboardEnabled = false
```

### Tools Tab

The built-in Tools tab contains:

- Theme switching and theme editing.
- Animation, transparency, and scale settings.
- Keybind manager.
- Favorites and recent actions.
- Notification history.
- Session FPS, ping, and duration.
- Player search and sorting.
- Public server browser.
- Reset actions.
- Developer event log and export.

## Themes

Built-in themes:

- `Default`
- `Dark`
- `Midnight`
- `Purple`
- `Green`

```lua
OrionLib:SetTheme("Midnight")
local Theme = OrionLib:GetTheme()
local Accent = OrionLib:GetThemeColor("Accent")
```

Create a custom theme:

```lua
OrionLib:CreateTheme("Ocean", {
    Main = Color3.fromRGB(10, 18, 28),
    Second = Color3.fromRGB(16, 30, 44),
    Stroke = Color3.fromRGB(36, 70, 92),
    Divider = Color3.fromRGB(24, 48, 64),
    Text = Color3.fromRGB(235, 245, 255),
    TextDark = Color3.fromRGB(135, 165, 185),
    Accent = Color3.fromRGB(40, 180, 220)
})

OrionLib:SetTheme("Ocean")
```

Change one color in the active theme:

```lua
OrionLib:ChangeThemeColor(
    "Accent",
    Color3.fromRGB(255, 180, 70)
)
```

## Profiles and Configuration

Controls are saved only when both conditions are met:

1. The window uses `SaveConfig = true`.
2. The control uses `Save = true` and a `Flag`.

```lua
OrionLib:SaveConfiguration("combat")
OrionLib:LoadConfiguration("combat")
OrionLib:SetProfile("combat")
print(OrionLib:GetProfile())
```

Legacy control values are stored in:

```text
ConfigFolder/ProfileName.txt
```

UI state is stored separately in:

```text
ConfigFolder/GameId.ui.txt
```

UI state includes:

- Window position.
- Window size.
- Selected tab.
- Selected theme.
- UI scale.
- Transparency.
- Animation preference.

Disable UI persistence with:

```lua
PersistUI = false
```

## Favorites and Recent Actions

Favorites can be declared on buttons or managed at runtime:

```lua
OrionLib:AddFavorite("Open inventory", function()
    print("Inventory opened")
end)

OrionLib:RemoveFavorite("Open inventory")
local Favorites = OrionLib:GetFavorites()
local Recent = OrionLib:GetRecentUsed()
```

Button clicks are automatically added to the recently used list. The built-in Tools tab can run stored favorites and recent actions.

## Notifications

```lua
OrionLib:MakeNotification({
    Name = "Success",
    Content = "The action completed.",
    Time = 4,
    Image = "rbxassetid://4384403532"
})
```

Notification entries remain in memory after the visual notification disappears:

```lua
local History = OrionLib:GetNotificationHistory()
OrionLib:ClearNotificationHistory()
```

## Developer Event Log

```lua
OrionLib:Log("system", "Feature initialized")
local Events = OrionLib:GetEventLog()
OrionLib:ClearEventLog()
```

The Tools tab can search, clear, and export the event log to `event-log.txt` inside the configured folder.

## Window and UI Management

```lua
OrionLib:SetBackground("rbxassetid://123456789", 0.5)
OrionLib:SetTheme("Dark")
OrionLib:Destroy()
```

The window can be dragged and resized. Position and size are persisted when `PersistUI` is enabled.

## Player and Server Tools

The Tools tab uses Roblox services directly:

- `Players:GetPlayers()` for the player list.
- `PlayerAdded` and `PlayerRemoving` for live updates.
- `Stats.Network.ServerStatsItem["Data Ping"]` for ping.
- `games.roblox.com/v1/games/{placeId}/servers/Public` for public servers.
- `TeleportService:TeleportToPlaceInstance` for joining a selected server.

HTTP requests, teleporting, and filesystem persistence depend on the execution environment. All server and teleport operations are guarded so unavailable capabilities do not crash the UI.

## Reset Options

The Tools tab provides:

- Reset tabs: clears search and selects the first tab.
- Reset preset: removes the active profile flag configuration file.
- Reset UI settings: restores the default theme, scale, transparency, animations, position, and size.

## Cleanup

Call `Destroy` when the hub is no longer needed:

```lua
OrionLib:Destroy()
```

The library tracks its managed connections and disconnects them when the main interface is destroyed.
