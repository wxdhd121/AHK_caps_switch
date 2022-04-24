;管理员运行
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%" 
    ExitApp
}

;无环境变量
#NoEnv

SetCapsLockState , AlwaysOff
SetStoreCapslockMode , Off

;高进程
Process Priority, , High

CoordMode , ToolTip, Screen	;设置tooltip基于全屏的坐标
CoordMode , Pixel

CapsLock::
    if GetKeyState("CapsLock", "T")
    {
        KeyWait , CapsLock, T0.3
        if not (ErrorLevel)
        {
            SetCapsLockState , Off
            sleep,100
            GetCaret(x, y)
            PixelGetColor , color, 1745, 1068 ;中英文检测方式，获取任务栏中英文提示处的像素颜色，显示中/英两种字的时候，该像素点颜色不一样，可根据自己的情况进行微调。
            If (color != 0xFFFFFF)
                ToolTip ,中, x, y - 25
            else
                ToolTip ,英, x, y - 25
            SetTimer , RemoveToolTip, -1000
        }
    }
    ; 大写锁定开启时，按下 CapsLock 键即可关闭大写锁定。 
else
    {
        KeyWait , CapsLock, T0.3
        if not (ErrorLevel)
        {
            Send , ^{Space}
            ; 短按 CapsLock 键，发送 Ctrl+Space 以切换中英文。
            GetCaret(x, y)
            PixelGetColor , color, 1745, 1068
            If (color = 0xFFFFFF)
                ToolTip ,中, x, y - 25
            else
                ToolTip ,英, x, y - 25
            SetTimer , RemoveToolTip, -1000
        } else
        {
            KeyWait , CapsLock
            SetCapsLockState , On
            GetCaret(x, y)
            ToolTip ,A, x, y - 25
            SetTimer , RemoveToolTip, -1000
            ; 长按 CapsLock 键 0.3 秒，仍可开启大写锁定。
        }

    }
Return

RemoveToolTip:
    SetTimer , RemoveToolTip, Off
    ToolTip
return

;======== 获取光标位置的函数 =========

; 获取光标位置（坐标相对于屏幕）
; From Acc.ahk by Sean, jethrow, malcev, FeiYue
GetCaret(Byref CaretX = "", Byref CaretY = "")
{
    static init
    CoordMode , Caret, Screen
    CaretX := A_CaretX, CaretY := A_CaretY
    if (!CaretX or !CaretY)
    Try {
        if (!init)
            init := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
        VarSetCapacity(IID, 16), idObject := OBJID_CARET := 0xFFFFFFF8
        , NumPut(idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID, "Int64")
        , NumPut(idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, IID, 8, "Int64")
        if DllCall("oleacc\AccessibleObjectFromWindow"
            , "Ptr", WinExist("A"), "UInt", idObject, "Ptr", &IID, "Ptr*", pacc) = 0
        {
            Acc := ComObject(9, pacc, 1), ObjAddRef(pacc)
            , Acc.accLocation(ComObj(0x4003, &x := 0), ComObj(0x4003, &y := 0)
            , ComObj(0x4003, &w := 0), ComObj(0x4003, &h := 0), ChildId := 0)
            , CaretX := NumGet(x, 0, "int"), CaretY := NumGet(y, 0, "int")
        }
    }
return { x: CaretX, y: CaretY }
}