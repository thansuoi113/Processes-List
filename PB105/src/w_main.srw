$PBExportHeader$w_main.srw
forward
global type w_main from window
end type
type dw_main from datawindow within w_main
end type
type cb_1 from commandbutton within w_main
end type
type str_process from structure within w_main
end type
end forward

type str_process from structure
	unsignedlong		StructSize
	unsignedlong		cntusage
	unsignedlong		processid
	unsignedlong		defaultheapid
	unsignedlong		moduleid
	unsignedlong		cntthreads
	unsignedlong		parentprocessid
	unsignedlong		pcpriclassbase
	long		dwflags
	character		FileName[256]
end type

global type w_main from window
integer width = 2359
integer height = 1408
boolean titlebar = true
string title = "Process"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
dw_main dw_main
cb_1 cb_1
end type
global w_main w_main

type prototypes
Function Long GetCurrentProcessId() Library "kernel32.dll"
Function Long CreateToolhelp32Snapshot(Long Flags, Long ProcessId) Library "kernel32.dll"
Function Integer Process32First(ULong Snapshot, Ref str_Process sProcess) Library "kernel32.dll" Alias For "Process32First;Ansi"
Function Integer Process32Next(ULong Snapshot, Ref str_Process sProcess) Library "kernel32.dll" Alias For "Process32Next;Ansi"
Function ULong GetWindowThreadProcessId(ULong hwnd, Ref ULong lpdwProcessId) Library "user32.dll"
Function ULong GetWindowText(ULong hwnd, Ref String lpString, ULong cch) Library "user32.dll" Alias For "GetWindowTextA;Ansi"

end prototypes
on w_main.create
this.dw_main=create dw_main
this.cb_1=create cb_1
this.Control[]={this.dw_main,&
this.cb_1}
end on

on w_main.destroy
destroy(this.dw_main)
destroy(this.cb_1)
end on

type dw_main from datawindow within w_main
integer width = 2304
integer height = 1120
integer taborder = 10
string title = "none"
string dataobject = "d_process"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type cb_1 from commandbutton within w_main
integer y = 1152
integer width = 402
integer height = 112
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Load"
end type

event clicked;str_Process lst_Process //Process structure
String ls_FileName[], ls_CurExeName //Up to 100 processes, can be improved
String ls_win_txt
ULong ln_ProcessID, ln_SameCount, ln_Snapshot
ULong ln_Circle, ln_Count
ULong ll_new, ll_handle
ln_ProcessID = GetCurrentProcessId() //Get the ID of the current process
If IsNull(ln_ProcessID) Or ln_ProcessID < 1 Then
	Return -1 //return if error occurs
End If

ln_Snapshot = CreateToolhelp32Snapshot(2,0) //Create a process snapshot on the heap
If (ln_Snapshot < 1) Then
	Return -1 //return if error occurs
End If

lst_Process.StructSize = 296 //Win32api Process structure size
ln_SameCount = 0 //The number of copies is 0
If Process32First(ln_Snapshot,lst_Process) = 0 Then
	Return -1 //Return if the first process fails
End If

ln_Count = 1
ls_FileName[ln_Count] = lst_Process.Filename //The listed process names are put into the array
//If the listed process ID is equal to the current process ID, then you know the name of the current process and save
If lst_Process.ProcessID = ln_ProcessID Then
	ls_CurExeName = lst_Process.Filename
End If

ls_win_txt = Space(200)
Do While True //Take the enumerated process names in a loop and put them into an array
	If Process32Next(ln_Snapshot, lst_Process) = 0 Then
		Exit //Enumerated
	End If
	
	ln_Count = ln_Count + 1
	ls_FileName[ln_Count] = lst_Process.Filename
	If lst_Process.ProcessID = ln_ProcessID Then
		ls_CurExeName = lst_Process.Filename
	End If
	
	ll_new = dw_main.InsertRow(0)
	dw_main.SetItem(ll_new, "process_no", lst_Process.ProcessID)
	dw_main.SetItem(ll_new, "process_file", ls_FileName[ln_Count])
	If GetWindowThreadProcessId(lst_Process.ProcessID, ll_handle) > 0 Then
		GetWindowText(ll_handle, ls_win_txt, 255)
		dw_main.SetItem(ll_new, "process_handle", ll_handle)
		dw_main.SetItem(ll_new, "process_nam", ls_win_txt)
	End If
Loop

dw_main.Sort()

end event

