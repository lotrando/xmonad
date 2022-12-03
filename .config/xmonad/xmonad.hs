-- Realist Xmonad Gentoo Desktop (c) 2021 -> ~/.xmonad/xmonad.hs

 -- Base
import XMonad
import System.Directory
import System.Exit (exitSuccess)
import System.IO (hPutStrLn)
import qualified XMonad.StackSet as W

 -- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

 -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Maybe (isJust)
import Data.Monoid
import Data.Tree
import qualified Data.Map as M

 -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doRectFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WorkspaceHistory

  -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ThreeColumns

  -- Layouts Modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))

-- Prompt
import Control.Arrow (first)
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Input
import XMonad.Prompt.Man
import XMonad.Prompt.Shell
import XMonad.Prompt.XMonad

-- Utilities
--import XMonad.Util.Dmenu
import XMonad.Util.Cursor
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Hacks (windowedFullscreenFixEventHook, javaHack, trayerAboveXmobarEventHook, trayAbovePanelEventHook)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

-- VARIABLES --

-- Set Ubuntu as default font
myFont = "xft:Ubuntu:weight=bold:pixelsize=11:antialias=true:hinting=true"
-- Sets Windows / Super key for Master key
myModMask = mod4Mask
-- Sets Alt key for use in Xprompts
altMask = mod1Mask
-- Sets Xfce4-terminal as default terminal
myTerminal = "urxvt"
-- Sets Firefox as default browser
myBrowser = "firefox"
-- Sets Sublime-text as default editor
myEditor = "subl"
-- Sets border width for windows
myBorderWidth = 1
-- Border color of normal windows
myNormColor   = "#81a2be"
-- Border color of focused windows
myFocusColor  = "#81a2be"
-- Screen Windows counts
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- Startup Hook --
myStartupHook = do
  setDefaultCursor xC_left_ptr
  setWMName "RXMD"
  spawnOnce "volumeicon"
  -- spawnOnce "nm-applet"

-- XPConfig --
myXPConfig = def
  { font                = "xft:Ubuntu:bold:size=10"
  , bgColor             = "#282c34"
  , fgColor             = "#c2c2cf"
  , bgHLight            = "#98c379"
  , fgHLight            = "#000000"
  , borderColor         = "#81a2be"
  , promptBorderWidth   = 1
  , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
  , height              = 32
  , historySize         = 0
  , historyFilter       = id
  , defaultText         = []
  , autoComplete        = Just 100000
  , showCompletionOnTab = False
  , searchPredicate     = fuzzyMatch
  , defaultPrompter     = id
  , alwaysHighlight     = True
  , maxComplRows        = Nothing
  }

google = S.searchEngine "google" "https://google.com/php?search="
searchList = [ ("g", S.google) ]

-- Layouts --
mySpacing i = spacingRaw False (Border 3 i i i) True (Border 3 i i i) True
mySpacing' i = spacingRaw True (Border 3 i i i) True (Border 3 i i i) True

tall     = renamed [Replace "T"]
           $ mySpacing 2
           $ limitWindows 4
           $ smartBorders
           $ windowNavigation
           $ ResizableTall 1 (3/100) (1/2) []
threeRow = renamed [Replace "R"]
           $ mySpacing 2
           $ limitWindows 3
           $ smartBorders
           $ windowNavigation
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
threeCol = renamed [Replace "C"]
           $ mySpacing 2
           $ limitWindows 3
           $ smartBorders
           $ windowNavigation
           $ ThreeCol 1 (3/100) (1/2)
grid     = renamed [Replace "G"]
           $ mySpacing 2
           $ limitWindows 6
           $ smartBorders
           $ windowNavigation
           $ mkToggle (single MIRROR)
           $ Grid (16/10)

-- The layout hook
myLayoutHook = avoidStruts
               $ mouseResize
               $ windowArrange
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout = withBorder myBorderWidth tall
                                           ||| threeRow
                                           ||| threeCol
                                           ||| grid

myWorkspaces = [" SYS ", " WWW ", " DEV ", " PHP ", " CODE ", " VBOX ", " MUS ", " MPV ", " GFX "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..]
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices


myShowWNameTheme = def
  { swn_font              = "xft:Ubuntu:bold:size=50"
  , swn_fade              = 2.0
  , swn_bgcolor           = "#282A2E"
  , swn_color             = "#EEEEEE"
  }


-- Managehook --
myManageHook = composeAll
  [ className =? "confirm"            --> doCenterFloat
  , className =? "file_progress"      --> doCenterFloat
  , className =? "dialog"             --> doCenterFloat
  , className =? "download"           --> doCenterFloat
  , className =? "error"              --> doCenterFloat
  , className =? "Gimp-2.10"          --> doFloat
  , className =? "Gimp-2.10"          --> doShift ( myWorkspaces !! 8 )
  , className =? "notification"       --> doFloat
  , className =? "splash"             --> doCenterFloat
  , className =? "mpv"                --> doCenterFloat
  , title =? "Visual Studio Code"     --> doShift ( myWorkspaces !! 4 )
  , title =? "Mozilla Firefox"        --> doShift ( myWorkspaces !! 1 )
  , className =? "VirtualBox Manager" --> doShift ( myWorkspaces !! 5 )
  , className =? "VirtualBox Manager" --> doCenterFloat
  , className =? "mpv"                --> doShift ( myWorkspaces !! 7 )
  , className =? "trayer-srg"         --> doIgnore
  , className =? "Audacious"          --> doIgnore
  , className =? "Nitrogen"           --> doRectFloat (W.RationalRect (1 / 4) (1 / 4) (1 / 2) (1 / 2))
  , className =? "Pcmanfm"            --> doCenterFloat
  , className =? "File-roller"        --> doCenterFloat
  , className =? "Qalculate-gtk"      --> doCenterFloat
  , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat
  , isFullscreen -->  doFullFloat
  ]

-- Keys --
myKeys =
  [
  -- Xmonad Restarts (Win+Shift+r)
      ("M-S-r", spawn "xmonad --restart")
  -- Xmonad Quit (Win+Shift+q)
    , ("M-S-q", io exitSuccess)
  -- Kill the currently focused client (Win+Shift+c)
    , ("M-S-c", kill1)
  -- Kill all windows on current workspace (Win+Shift+a)
    , ("M-S-x", killAll)
  -- Rofi DRUN Prompt (Win+Shift+Enter)
    , ("M-S-<Return>", spawn "launcher")
  -- Rofi Powermenu (Win+Shift+p)
    , ("M-S-p", spawn "powermenu")
  -- Rofi Apps (Win+Shift+Backspace)
    , ("M-S-<Backspace>", spawn "apps")
  -- Run myTerminal (Win+<Enter>)
    , ("M-<Return>", spawn (myTerminal))
  -- Run myBrowser (Win+Alt+f)
    , ("M-M1-b", spawn (myBrowser))
  -- Run myEditor (Win+Alt+e)
    , ("M-M1-e", spawn (myEditor))
  -- Run Pcmanfm (Win+Alt+t)
    , ("M-M1-f", spawn "pcmanfm")
  -- Run Htop (Win+Alt+h)
    , ("M-M1-t", spawn (myTerminal ++ " -e btop"))
  -- Run Alsamixer (Win+Alt+m)
    , ("M-M1-m", spawn (myTerminal ++ " -e pulsemixer"))
  -- Switch to next layout
    , ("M-<Tab>", sendMessage NextLayout)
  -- Toggles noborder/full
    , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)
  -- Toggles noborder
    , ("M-S-n", sendMessage $ MT.Toggle NOBORDERS)
  -- Shrink horiz window width
    , ("M-h", sendMessage Shrink)
  -- Expand horiz window width
    , ("M-l", sendMessage Expand)
  -- Shrink vert window width
    , ("M-M1-j", sendMessage MirrorShrink)
  -- Exoand vert window width
    , ("M-M1-k", sendMessage MirrorExpand)
  -- Switch focus to next monitor
    , ("M-.", nextScreen)
  -- Switch focus to prev monitor
    , ("M-,", prevScreen)
  -- Shifts focused window to next Workspace
    , ("M-S-<Right>", shiftTo Next nonNSP >> moveTo Next nonNSP)
  -- Shifts focused window to prev Workspace
    , ("M-S-<Left>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)
  -- Toggles my 'floats' layout
    , ("M-f", sendMessage (T.Toggle "floats"))
  -- Push floating window back to tile
    , ("M-t", withFocused $ windows . W.sink)
  -- Push ALL floating windows to tile
    , ("M-S-t", sinkAll)
  -- Decrease window spacing
    , ("M-d", decWindowSpacing 2)
  -- Increase window spacing
    , ("M-i", incWindowSpacing 2)
  -- Decrease screen spacing
    , ("M-S-d", decScreenSpacing 2)
  -- Increase screen spacing
    , ("M-S-i", incScreenSpacing 2)
  -- Move focus to the master window
    , ("M-m", windows W.focusMaster)
  -- Move focus to the next window
    , ("M-j", windows W.focusDown)
  -- Move focus to the prev window
    , ("M-k", windows W.focusUp)
  -- Swap the focused window and the master window
    , ("M-S-m", windows W.swapMaster)
  -- Swap focused window with next window
    , ("M-S-j", windows W.swapDown)
  -- Swap focused window with prev window
    , ("M-S-k", windows W.swapUp)
  -- Moves focused window to master, others maintain order
    , ("M-<Backspace>", promote)
  -- Rotate all windows except master and keep focus in place
    , ("M-S-<Tab>", rotSlavesDown)
  -- Rotate all the windows in the current stack
    , ("M-C-<Tab>", rotAllDown)

  ]

-- Keys End --

  -- Search prompt (Win+S and g) (google)
    ++ [("M-s " ++ k, S.promptSearch myXPConfig f) | (k,f) <- searchList ]
  -- Search prompt (Win+S+s and g) (selected text + google)
    ++ [("M-S-s " ++ k, S.selectSearch f) | (k,f) <- searchList ]
      where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
            nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

-- Main --
main = do
  home <- getHomeDirectory
  xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0" -- One Monitor
  -- xmproc1 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc1" -- Dual Monitor 1
  -- xmproc2 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc2" -- Dual Monitor 2
  xmonad $ ewmh def
    { manageHook          = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
    , focusFollowsMouse   = True
    , handleEventHook     = serverModeEventHookCmd <+> serverModeEventHook <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
    , modMask             = myModMask
    , terminal            = myTerminal
    , startupHook         = myStartupHook
    , layoutHook          = showWName' myShowWNameTheme $ myLayoutHook
    , workspaces          = myWorkspaces
    , borderWidth         = myBorderWidth
    , normalBorderColor   = myNormColor
    , focusedBorderColor  = myFocusColor
    , logHook             = workspaceHistoryHook <+> dynamicLogWithPP xmobarPP
      { 
        ppOutput          = \x -> hPutStrLn xmproc0 x
      --  ppOutput          = \x -> hPutStrLn xmproc1 x >> hPutStrLn xmproc2 x
      , ppCurrent         = xmobarColor "#b5bd68" "" . wrap "<box type=Bottom width=1 mb=2>" "</box>" .clickable
      , ppVisible         = xmobarColor "#707880" "" . wrap "<box type=Bottom width=1 mb=2>" "</box>" .clickable
      , ppHidden          = xmobarColor "#81a2be" "" . wrap "<box type=Bottom width=1 mb=2>" "</box>" .clickable
      , ppUrgent          = xmobarColor "#a54242" "" . wrap "<box type=Bottom width=1 mb=2>" "</box>" .clickable
      , ppHiddenNoWindows = xmobarColor "#707880" "" . wrap "" "" .clickable
      , ppTitle           = xmobarColor "#c5c8c6" "" . shorten 80
      , ppSep             = "<fc=#777777><fn=1> | </fn></fc>"
      , ppExtras          = [windowCount]
      , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
      } >> updatePointer (0.50, 0.50) (0, 0)
    }
    `additionalKeysP` myKeys
