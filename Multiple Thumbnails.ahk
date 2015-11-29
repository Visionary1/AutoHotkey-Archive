VarSetCapacity(pf,4), DllCall("Dwmapi\DwmIsCompositionEnabled","int*",pf)
if !NumGet(pf)
{
    MsgBox, 16, DWM, Please enable DWM on your service!
    ExitApp
}

global Bracket:=[],oShell := ComObjCreate("Shell.Application"),Flag
global isShowBtn,d_margin,ScreenHeight,ScreenWidth,d_width
global hgui , dtl , vis  , swa ,top_height,max_row,d_height


Gui,1:new,+hwndhgui -Caption +LastFound +AlwaysOnTop +E0x8000000
Gui, 1:Color, EEAA99
WinSet, TransColor, EEAA99
OnMessage(0x202,hgui,"Raid")
EnumWindows := RegisterCallback("EnumWindows")
HU.ResolutionChanges.Insert({thread:h_thread,Code:"Gosub Parameters`ngosub,dtl_refresh"})
Gosub Parameters     ; 初始化参数


dwm_view:
    dtl := [],h_left:=isShowBtn ? d_width : 0
    DllCall("EnumWindows","ptr",EnumWindows,"int",0)
    h_height := d_margin
    loop % dtl.maxindex()
    {
        VarSetCapacity(phThumbnailId,A_PtrSize,0)
        hr := Dllcall("Dwmapi\DwmRegisterThumbnail","uint",hgui,"uint",dtl[A_Index]["id"],"ptr",&phThumbnailId)
        if !hr
        {
            hThumbnailId := NumGet(phThumbnailId)
            dtl[A_Index].Insert("tid",hThumbnailId)
			
            ; 取得窗口原始大小，w_
            VarSetCapacity(lpwndpl,44),NumPut(44,lpwndpl)
            ,DllCall("GetWindowPlacement","uint",dtl[A_Index].id,"ptr",&lpwndpl)
            ,flags := NumGet(lpwndpl,4,"int") , showcmd := NumGet(lpwndpl,8,"int")
            ,w_left := NumGet(lpwndpl,28,"int") , w_top := NumGet(lpwndpl,32,"int") , w_right := NumGet(lpwndpl,36,"int") , w_bottom := NumGet(lpwndpl,40,"int")
            
            ; source窗口大小，R_
            R_left := 0 , R_top := 0
            if (flags=2)  ; 最大化窗口
                R_right := ScreenWidth , R_bottom := ScreenHeight
            else
                R_right := w_right - w_left , R_bottom := w_bottom - w_top
            opacity := 255 , fVisible := 1 , fSourceClientAreaOnly := 1

            ; target窗口大小，d_

        h_right:=h_left+d_width+d_margin
        if (h_right < ScreenWidth)
        {
            dtl[A_Index].left := h_left+d_margin
        }
        else
        {
            dtl[A_Index].left :=h_right:=0
            h_height+=d_height+d_margin*2
        }

        dtl[A_Index].top :=h_height
        h_left :=dtl[A_Index].right:=dtl[A_Index].left+d_width
        dtl[A_Index].bottom := dtl[A_Index].top+d_height


        if !Bracket["__" A_Index]
        {
            gui,1:add,button, % "+hwndhgui2 w"  d_width " h" dtl[A_Index].bottom  " x" dtl[A_Index].left " y" dtl[A_Index].top " V__" A_Index
            OnMessage(0x202,hgui2,"Raid")
            Bracket["__" A_Index]:=h:=Abs(hgui2)
        }
        else
        {
            GuiControl, 1:Move,% "__" A_Index, % "w"  d_width " h" dtl[A_Index].bottom  " x" dtl[A_Index].left " y" dtl[A_Index].top
            h:=Bracket["__" A_Index]
        }
        Flag[h]:=dtl[A_Index]



        VarSetCapacity(ptnProperties,45,0),NumPut(3,ptnProperties)
        ,NumPut(dtl[A_Index].left,ptnProperties,4,"Int") , NumPut(dtl[A_Index].top,ptnProperties,8,"Int") , NumPut(dtl[A_Index].right,ptnProperties,12,"Int") , NumPut(dtl[A_Index].bottom,ptnProperties,16,"Int")
        ,NumPut(R_left,ptnProperties,20,"Int") , NumPut(R_top,ptnProperties,24,"Int") , NumPut(R_right,ptnProperties,28,"Int") , NumPut(R_bottom,ptnProperties,32,"Int")

        hr := Dllcall("Dwmapi\DwmUpdateThumbnailProperties","uint",hThumbnailId,"ptr",&ptnProperties)
        if hr
            msgbox % "error code: " hr "," dtl[A_Index].title
        }
    }


    w := ScreenWidth , h := h_height+d_height+d_margin , x :=0 , y := ScreenHeight-h

    IfWinNotExist, ahk_id %hgui%
        gui,1:show,NA   w%w% h%h% x%x% y%y%
    else
        WinMove,ahk_id %hgui%,,%x%,%y%,%w%,%h%
return

Parameters:
    SysGet,mon_,MonitorWorkArea
    Flag:=[]
    ,isShowBtn :=   0
    ,d_margin := 5  ; 边距
    ,Stripes:=(Taskbar() < 4)
    ,ScreenHeight     :=  mon_bottom - (Stripes?0:mon_top)  ; 工作区高度
    ,ScreenWidth     := mon_right - (Stripes?0:mon_left)  ; 工作区宽度
    ,d_width        := ScreenHeight >ScreenWidth  ? ScreenWidth/6-d_margin*1.2 : 150
    , vis := 1 , swa := 0
    ,top_height     := isShowBtn?d_width:0 ; 顶部高度
    ,max_row         := (ScreenWidth-top_height)//(d_width+d_margin) ; 每列数量
    ,d_height    := d_width*ScreenHeight// ScreenWidth  

    if isShowBtn
    {
        if Cutting
        {
            w :=(d_width-5)/2,Cutting:=w+5
            GuiControl, 1:Move,sdfsdf1, x5 y5 H%d_height% w%w%
            GuiControl, 1:Move,sdfsdf2, x%Cutting% y5 H%d_height% w%w%
        }
        else
        {
            w :=(d_width-5)/2,Cutting :=w+5
            gui,1:add,button,x5 y5 H%d_height% w%w% gdtl_refresh vsdfsdf1,刷新
            gui,1:add,button,x%Cutting% y5 H%d_height% w%w% gdtl_quit vsdfsdf2 ,退出
        }
    }
return

btn_workarea:
        ; 设定工作区
        GuiControl,,btn_wa,% (swa := !swa)?"Restore Work Area":"Set Work Area"
        VarSetCapacity(wa,16,0)
        ,NumPut(mon_left,wa,0,"int")
        ,NumPut(mon_top,wa,4,"int")
        ,NumPut(mon_right-(swa?w:0),wa,8,"int")
        ,NumPut(mon_bottom,wa,12,"int")
        DllCall("SystemParametersInfo","uint",0x2F,"uint",0,"ptr",&wa,"uint",0)
        return

Raid(wParam, lParam, msg, hwnd){
    static r,t
    f:=Flag[hwnd]
    if f.class
    {

        if (f.class = "Progman")
            oShell.ToggleDesktop()
        else
        {
    
            if WinExist(id:="ahk_id " f.id)             
            {
                WinActivate,% id
                if ((r=hwnd) and (A_TickCount- t)<700 )
                {    
                    WinGet,a,minmax,% id
                    if a=0
                    WinMaximize,% id
                    else
                    WinRestore,% id
                }
                r:=hwnd,t:=A_TickCount
            }
            else
            gosub,dtl_refresh
        }

    }
    else
    {
        if ((r=hwnd) and (A_TickCount- t)<700 )
        gosub,dtl_refresh
        r:=hwnd,t:=A_TickCount
    }
    Return
}

; 热键 ctrl + / 刷新缩略图

dtl_refresh:
loop % dtl.maxindex()    
    Dllcall("Dwmapi\DwmUnregisterThumbnail","uint",dtl[A_Index]["tid"])
    
for i,n in Bracket
    GuiControl, 1:Move,% "__" A_Index, h0 w0
gosub, dwm_view
return

; 热键 win + esc 退出
GuiClose:
dtl_quit:
ExitApp

dtl_show:
    if vis
        WinHide,ahk_id %hgui%
    else
    {
        gosub dtl_refresh
        WinShow,ahk_id %hgui%
    }
    vis := !vis
return

; 枚举窗体
EnumWindows(hwnd)
{
    if  DllCall("IsWindowVisible","uint",hwnd) && (hwnd=DllCall("GetAncestor","uint",hwnd,"uint",3))
    {
        WinGetTitle,title,ahk_id %hwnd%
        if title
        {
            WinGetClass,class,ahk_id %hwnd%
            if (class="Button")   ; 跳过开始菜单按钮
                return 1
            else if (class="Progman")  ; 桌面
                title := "桌面"
            else if (hwnd=hgui)  ; 跳过自己
                return 1
            else if (DllCall("GetWindowLongW","uint",hwnd,"int",-20) & 0x80)   ; 跳过toolwindow类型窗口
                return 1
            dtl.Insert({id:hwnd,title:title,class:class})
        }
    }
    return 1
}


Taskbar(){
    WinGetPos,x,y,w,h,ahk_class Shell_TrayWnd
    Return x>0?3:y>0?4:w>h?2:1 ; left, top, right, bottom = 1, 2, 3, 4
}
