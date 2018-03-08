#SingleInstance,Force
DetectHiddenWindows,On
IDS:=[],Hotkey:=[],MyWindows:=[]
global xx:=New XML("Settings"),v:=[]
ComObjError(0)
if(xx.SSN("//Settings/HotKey")){
	All:=xx.SN("//Settings/HotKey")
	Top:=xx.Add("WorkSpaces")
	while(aa:=All.Item[A_Index-1])
		Top.AppendChild(aa)
}
GetWindowPositions()
/*
	Just get the default screen, and call that screen 1{
		fudge the rest and make GUI's for those screens
		have a listview that the user can update that screen to whatever
		identifier number that they choose.
	}
	Create Explorer Window
	Lock Down Window Positions
	Add More Windows To Chrome things
*/
Menu,Tray,NoStandard
Menu,Tray,Add,Open GUI,Gui
Menu,Tray,Default,Open GUI
Menu,Tray,Add,Exit,Exit
if(A_UserName="maest")
	Gui(1)
else
	PopulateSpaces()
GetWindows(1)
OnExit,Exit
List:=Monitors()
/*
	All:=xx.SN("//HotKey")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		Hotkey,% ea.HotKey,Launch,On
	}
	All:=xx.SN("//PassWord/descendant::Key")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		if(ea.Key)
			Hotkey,% ea.Key,PassWordInput,On
	}
*/
/*
	for a,b in List.List.1
		m(a,b)
	Get the Grid from Image Viewer{
		have it work with this so that if they want to open 4 windows
		have it equally space them and arrange them.
		make a grid tag for the windows
	}
*/
return
^!F5::
First:=1
Second:=Third:=Fourth:=""
return
^!F6::
if(First&&!Second&&!Third&&!Fourth)
	Second:=1
else
	First:=Second:=Third:=Fourth:=""

return
^!F7::
if(First&&Second&&!Third&&!Fourth)
	Third:=1
else
	First:=Second:=Third:=Fourth:=""
return
^!F8::
if(First&&Second&&Third&&!Fourth){
	IniRead,PW,PW.ini,Password,Main,0
	if(!PW){
		InputBox,Password,Enter Your Password,Password Please
		IniWrite,% Encode(Password),PW.ini,Password,Main
		IniRead,PW,PW.ini,Password,Main,0
	}
	Clip:=clipboardall
	Clipboard:=Decode(PW)
	While(clipboard!=Decode(PW))
		Sleep,50
	Sleep,100
	Send,^v
	Clipboard:=Clip
	Send,{Enter}
	First:=Second:=Third:=Fourth:=""
}else
	First:=Second:=Third:=Fourth:=""
return
Encode(text){
	IfEqual,text,,return
	cp:=0,VarSetCapacity(rawdata,StrPut(text,"UTF-8")),sz:=StrPut(text,&rawdata,"UTF-8")-1,DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"ptr",0,"uint*",cp),VarSetCapacity(str,cp*(A_IsUnicode?2:1)),DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"str",str,"uint*",cp)
	return str
}
Decode(string){ ;original http://www.autohotkey.com/forum/viewtopic.php?p=238120#238120
	if(string="")
		return
	DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",0,"uint*",cp:=0,"ptr",0,"ptr",0),VarSetCapacity(bin,cp),DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",&bin,"uint*",cp,"ptr",0,"ptr",0)
	return StrGet(&bin,cp,"UTF-8")
}
^!F9::
DriveGet,Drives,List
for a,b in StrSplit(Drives){
	DriveGet,Label,Label,%b%:
	if(Label="Google Drive File Stream"){
		GoogleDrive:=b
	}
}
for a,b in StrSplit(Drives){
	DriveGet,Label,Label,%b%:
	if(Label="Google Drive File Stream"){
		GoogleDrive:=b
	}
	if(Label="DRIVE"){
		FormatTime,Time,%A_Now%,dd.MM.yy
		BackupFolder:=b ":\Backups\" Time "\"
		FileCreateDir,%BackupFolder%
		FileCreateDir,%BackupFolder%\C
		FileCreateDir,%BackupFolder%\D
		FileCreateDir,%BackupFolder%\P
		RunWait,Robocopy /E "C:\PANDORA" "%BackupFolder%\C\PANDORA"
		RunWait,Robocopy /E "C:\ahk" "%BackupFolder%\C\ahk"
		RunWait,Robocopy /E "C:\Users\hiroshima\Desktop" "%BackupFolder%\C\Desktop"
		RunWait,Robocopy /E "D:\" "%BackupFolder%\C\Desktop"
		for a,b in {DC:"D:\DC",Drive:"D:\Drive",LIVE:"D:\LIVE",Productions:"D:\Productions"}{
			RunWait,Robocopy /E "%b%" "%BackupFolder%\D\%a%"
		}
		m("This Will Open Explorer Windows")
		Run,Explorer.exe "%BackupFolder%P"
		Run,Explorer.exe "%GoogleDrive%:\"
		Sleep,1000
		Send,#{Left}
		Sleep,500
		Send,{Enter}
	}else
		m("Drive unavailable.")
}
return
m(x*){
	static list:={btn:{oc:1,ari:2,ync:3,yn:4,rc:5,ctc:6},ico:{"x":16,"?":32,"!":48,"i":64}},msg:=[]
	list.title:="WorkSpaces 2",list.def:=0,list.time:=0,value:=0,txt:=""
	for a,b in x
		obj:=StrSplit(b,":"),(vv:=List[obj.1,obj.2])?(value+=vv):(list[obj.1]!="")?(List[obj.1]:=obj.2):txt.=b "`n"
	msg:={option:value+262144+(list.def?(list.def-1)*256:0),title:list.title,time:list.time,txt:txt}
	Sleep,120
	MsgBox,% msg.option,% msg.title,% msg.txt,% msg.time
	for a,b in {OK:value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
		IfMsgBox,%a%
			return b
}
GetWindows(CreateList:=0,Window:="ahk_exe Chrome.exe"){
	static WindowList:=[]
	WinGet,ID,list,%Window%
	if(Window="Explorer"){
		for window in ComObjCreate("Shell.Application").Windows{
			if(CreateList&&!xx.SSN("//*[@hwnd='" Window.HWND "']"))
				xx.Add("Exist/HWND",{hwnd:Window.hwnd},,1)
			if(!CreateList&&!Node:=xx.SSN("//*[@hwnd='" Window.HWND "']"))
				return Window.HWND
		}
		return
	}
	Loop,%ID%{
		HWND:=ID%A_Index%,HWND:=HWND+0
		WinGetTitle,Title,ahk_id%HWND%
		/*
			if(!Title){
				m("Starting OVer: " HWND)
				return GetWindows(0,Window)
			}
		*/
		if(Window="ahk_exe Chrome.exe"){
			if(SubStr(Title,-12)="Google Chrome"){
				if(CreateList)
					xx.Add("Exist/HWND",{hwnd:hwnd},,1)
				if(!CreateList&&!xx.SSN("//*[@hwnd='" HWND "']"))
					return HWND
		}}else{
			if(CreateList){
				xx.Add("Exist/HWND",{hwnd:hwnd},,1)
			}
			/*
				Explorer windows are a pain in my ass!
				I think there is a way to get all of the explorer windows.
				use that rather than the thing I am doing....
			*/
			if(!CreateList&&!Node:=xx.SSN("//*[@hwnd='" HWND "']"))
				return HWND
		}
}}
Monitors(){
	SysGet,Primary,MonitorPrimary
	SysGet,Count,MonitorCount
	List:=[]
	Loop,%Count%{
		SysGet,Monitor,MonitorWorkArea,%A_Index%
		List[A_Index]:={Top:MonitorTop,Left:MonitorLeft,Right:MonitorRight,Bottom:MonitorBottom}
	}return {Primary:Primary,List:List}
}
Class XML{
	keep:=[]
	__Get(x=""){
		return this.XML.xml
	}__New(param*){
		if(!FileExist(A_ScriptDir "\lib"))
			FileCreateDir,%A_ScriptDir%\lib
		root:=param.1,file:=param.2,file:=file?file:root ".xml",temp:=ComObjCreate("MSXML2.DOMDocument"),temp.SetProperty("SelectionLanguage","XPath"),this.XML:=temp,this.file:=file,XML.keep[root]:=this
		if(Param.3)
			temp.preserveWhiteSpace:=1
		if(FileExist(file)){
			ff:=FileOpen(file,"R","UTF-8"),info:=ff.Read(ff.Length),ff.Close()
			if(info=""){
				this.XML:=this.CreateElement(temp,root)
				FileDelete,%file%
			}else
				temp.LoadXML(info),this.XML:=temp
		}else
			this.XML:=this.CreateElement(temp,root)
		SplitPath,file,,dir
		if(!FileExist(dir))
			FileCreateDir,%dir%
	}Add(XPath,att:="",text:="",dup:=0){
		p:="/",add:=(next:=this.SSN("//" XPath))?1:0,last:=SubStr(XPath,InStr(XPath,"/",0,0)+1)
		if(!next.xml){
			next:=this.SSN("//*")
			for a,b in StrSplit(XPath,"/")
				p.="/" b,next:=(x:=this.SSN(p))?x:next.AppendChild(this.XML.CreateElement(b))
		}if(dup&&add)
			next:=next.ParentNode.AppendChild(this.XML.CreateElement(last))
		for a,b in att
			next.SetAttribute(a,b)
		if(text!="")
			next.text:=text
		return next
	}CreateElement(doc,root){
		return doc.AppendChild(this.XML.CreateElement(root)).ParentNode
	}EA(XPath,att:=""){
		list:=[]
		if(att)
			return XPath.NodeName?SSN(XPath,"@" att).text:this.SSN(XPath "/@" att).text
		nodes:=XPath.NodeName?XPath.SelectNodes("@*"):nodes:=this.SN(XPath "/@*")
		while(nn:=nodes.item[A_Index-1])
			list[nn.NodeName]:=nn.text
		return list
	}Find(info*){
		static last:=[]
		doc:=info.1.NodeName?info.1:this.xml
		if(info.1.NodeName)
			node:=info.2,find:=info.3,return:=info.4!=""?"SelectNodes":"SelectSingleNode",search:=info.4
		else
			node:=info.1,find:=info.2,return:=info.3!=""?"SelectNodes":"SelectSingleNode",search:=info.3
		if(InStr(info.2,"descendant"))
			last.1:=info.1,last.2:=info.2,last.3:=info.3,last.4:=info.4
		if(InStr(find,"'"))
			return doc[return](node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/.." (search?"/" search:""))
		else
			return doc[return](node "[.='" find "']/.." (search?"/" search:""))
	}Get(XPath,Default){
		text:=this.SSN(XPath).text
		return text?text:Default
	}ReCreate(XPath,new){
		rem:=this.SSN(XPath),rem.ParentNode.RemoveChild(rem),new:=this.Add(new)
		return new
	}Save(x*){
		if(x.1=1)
			this.Transform()
		if(this.XML.SelectSingleNode("*").xml="")
			return m("Errors happened while trying to save " this.file ". Reverting to old version of the XML")
		FileName:=this.file?this.file:x.1.1,ff:=FileOpen(FileName,"R"),text:=ff.Read(ff.length),ff.Close()
		if(ff.encoding!="UTF-8")
			FileDelete,%FileName%
		if(!this[])
			return m("Error saving the " this.file " XML.  Please get in touch with maestrith if this happens often")
		if(!FileExist(FileName))
			FileAppend,% this[],%FileName%,UTF-8
		else if(text!=this[])
			file:=FileOpen(FileName,"W","UTF-8"),file.Write(this[]),file.Length(file.Position),file.Close()
	}SSN(XPath){
		return this.XML.SelectSingleNode(XPath)
	}SN(XPath){
		return this.XML.SelectNodes(XPath)
	}Transform(Loop:=1){
		static
		if(!IsObject(xsl))
			xsl:=ComObjCreate("MSXML2.DOMDocument"),xsl.loadXML("<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""><xsl:output method=""xml"" indent=""yes"" encoding=""UTF-8""/><xsl:template match=""@*|node()""><xsl:copy>`n<xsl:apply-templates select=""@*|node()""/><xsl:for-each select=""@*""><xsl:text></xsl:text></xsl:for-each></xsl:copy>`n</xsl:template>`n</xsl:stylesheet>"),style:=null
		Loop,%Loop%
			this.XML.TransformNodeToObject(xsl,this.xml)
	}Under(under,node,att:="",text:="",list:=""){
		new:=under.AppendChild(this.XML.CreateElement(node)),new.text:=text
		for a,b in att
			new.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			new.SetAttribute(b,att[b])
		return new
	}
}
SSN(node,XPath){
	return node.SelectSingleNode(XPath)
}
SN(node,XPath){
	return node.SelectNodes(XPath)
}
Gui(MonitorChange:=0){
	Gui,Color,0,0
	Gui,+hwndMain
	v.ID:="ahk_id" Main,v.Main:=Main
	Gui,Font,c0xAAAAAA
	Gui,Add,TreeView,w500 h500 AltSubmit gMainTV
	FileRead,ChangeLog,Lib\master ChangeLog.txt
	RegExMatch(ChangeLog,"OU)\x22message\x22:\x22(.*)\x22,",Info)
	Gui,Add,Edit,x+M w200 h500,% "Version Information:`r`n" RegExReplace(Info.1,"\\r\\n","`r`n")
	Gui,Add,Button,xm gCreatePassWordSequence,Create &PassWord Sequence
	Gui,Add,Button,xm gCreateChrome,Create &Chrome Window
	Gui,Add,Button,xm gCreateExplorerWindow,Create &Explorer Window
	Gui,Add,Button,xm gAddExplorerWindow,&Add Explorer Window To The Selected WorkSpace
	Gui,Add,Button,xm gAddChromeWindow,Add Chrome Window To The &Selected WorkSpace
	Gui,Add,Button,xm gCheckForUpdate,Check For Update
	Gui,Add,Button,xm gUpdateScript,Update Script
	Gui,Add,Button,Hidden Default,OK
	Gui,Show,,WorkSpaces 2
	Hotkey,IfWinActive,%ID%
	/*
		for a,b in {"~Enter":"Enter","~Delete":"Delete"}
			Hotkey,%a%,%b%,On
	*/
	Hotkey,IfWinActive
	PopulateSpaces()
	if(MonitorChange){
		if(xx.SN("//Monitors/Monitor").Length>1){
			AdjustMonitors()
		}else{
		}
	}
	/*
		HotKey,~Enter,Enter,On
	*/
	return
	GuiClose:
	for a,b in v.Windows
		Gui,%b%:Destroy
	Gui,1:Destroy
	return
}
AdjustMonitors(){
	All:=xx.SN("//Monitors/Monitor"),v.Windows:=[]
	WinGetPos,x1,y1,w1,h1,% v.ID
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		Win:="Show" A_Index
		v.Windows.Push(Win)
		Gui,%Win%:Destroy
		Gui,%Win%:Default
		Gui,+HWNDHWND
		Gui,Color,0,0
		Gui,Font,s100 c0xAAAAAA
		Gui,Add,Text,,%A_Index%
		Gui,Show,Hide AutoSize
		WinGetPos,x,y,w,h,ahk_id%HWND%
		AddTop:=Round(((ea.Bottom-ea.Top)/2)-(h/2))
		AddLeft:=Round(((ea.Right-ea.Left)/2)-(w/2))
		Gui,Show,% "x" (A_Index=1?(ea.Left+x1+w1):ea.Left+AddLeft) " y" ea.Top+AddTop,Window%A_Index%
	}
	WinActivate,% v.ID
}
PopulateSpaces(SetLast:=0){
	Gui,1:Default
	for a,b in v.CurrentHotkeys
		Hotkey,%a%,Off
	v.CurrentHotkeys:=[]
	if(SetLast){
		All:=xx.SN("//*[@last]")
		while(aa:=All.Item[A_Index-1])
			aa.RemoveAttribute("last")
		xx.SSN("//*[@tv='" TV_GetSelection() "']").SetAttribute("last",1)
	}GuiControl,-Redraw,SysTreeView321
	All:=xx.SN("//WorkSpaces/descendant-or-self::*|//PassWord/descendant-or-self::*|//Explorer/descendant-or-self::*"),TV_Delete()
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		if(aa.NodeName="HotKey"){
			aa.SetAttribute("tv",TV_Add(Convert_Hotkey(ea.HotKey),SSN(aa.ParentNode,"@tv").text))
			if(ea.Hotkey){
				HotKey,IfWinActive
				Hotkey,% ea.HotKey,Launch,On
				v.CurrentHotkeys[ea.Hotkey]:="Launch"
		}}else if(aa.NodeName="Window"){
			aa.SetAttribute("tv",TV_Add("Chrome - " ea.URL,SSN(aa.ParentNode,"@tv").text))
		}else if(aa.NodeName="PassWord")
			aa.SetAttribute("tv",TV_Add("Password",SSN(aa.ParentNode,"@tv").text))
		else if(aa.NodeName="Key"){
			aa.SetAttribute("tv",TV_Add("Key: " (ea.Hotkey?Convert_Hotkey(ea.Hotkey):"Undefined"),SSN(aa.ParentNode,"@tv").text))
			if(ea.Hotkey){
				HotKey,IfWinActive
				Hotkey,% ea.Hotkey,PassWordInput,On
				v.CurrentHotkeys[ea.Hotkey]:="PassWordInput"
			}
		}else if(aa.NodeName="Explorer"){
			aa.SetAttribute("tv",TV_Add("Folder: " ea.Folder,SSN(aa.ParentNode,"@tv").text))
		}
	}
	/*
		HotKey,~Enter,Enter,On
	*/
	GuiControl,+Redraw,SysTreeView321
	if(tv:=xx.SSN("//*[@last]/@tv").text)
		TV_Modify(tv,"Select Vis Focus")
}
CheckForUpdate(){
	static URL:="https://api.github.com/repos/maestrith/WorkSpaces-2/commits/$1"
	Branch:="master"
	sub:=A_NowUTC
	sub-=A_Now,hh
	FileGetTime,Time,%A_ScriptFullPath%
	Time+=sub,hh
	ea:=xx.EA("//github"),token:=ea.token?"?access_token=" ea.token:"",http:=ComObjCreate("WinHttp.WinHttpRequest.5.1"),http.Open("GET",RegExReplace(URL,"\$1",Branch) "?refresh=" A_Now token)
	if(proxy:=xx.SSN("//proxy").text)
		http.SetProxy(2,proxy)
	http.Send(),RegExMatch(http.ResponseText,"iUO)\x22date\x22:\x22(.*)\x22",found),Date:=RegExReplace(found.1,"\D")
	if(Startup="1"){
		if(Reset:=http.GetResponseHeader("X-RateLimit-Reset")){
			Seventy:=19700101000000
			for a,b in {s:Reset,h:-sub}
				EnvAdd,Seventy,%b%,%a%
			xx.Add("autoupdate",{Reset:Seventy})
			if(Time>Date)
				return
		}else
			return
	}File:=FileOpen("Lib\" Branch " ChangeLog.txt","rw")
	File.Seek(0)
	File.Write(Update:=RegExReplace(RegExReplace(URLDownloadToVar(RegExReplace(URL,"\$1",Branch) "?refresh=" A_Now),"\R","`r`n"),Chr(127),"`r`n"))
	File.Length(File.Position)
	File.Close()
	if(Time<Date)
		Update:=Update
	else
		Update:="No New Updates"
	if(!found.1)
		Update:=http.ResponseText
	RegExMatch(Update,"OU)\x22message\x22:\x22(.*)\x22,",Message)
	ControlSetText,Edit1,% "Version Information:`r`n" RegExReplace(Message.1,"\\r\\n","`r`n"),%ID%
}
URLDownloadToVar(URL){
	http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	if(proxy:=Settings.SSN("//proxy").text)
		http.SetProxy(2,proxy)
	http.Open("GET",URL,1)
	http.SetRequestHeader("Pragma","no-cache")
	http.SetRequestHeader("Cache-Control","no-cache")
	http.Send(),http.WaitForResponse
	return http.ResponseText
}
UpdateScript(){
	Info:=URLDownloadToVar(RegExReplace("https://raw.githubusercontent.com/maestrith/WorkSpaces-2/master/WorkSpaces%202.ahk?refresh=" A_Now,"\$1",Branch))
	xx.Save(1)
	if(InStr(Info,"Look For This Text")){
		SplitPath,A_ScriptFullPath,,Dir,Ext,NNE
		if(!FileExist("Backup"))
			FileCreateDir,Backup
		FileMove,%A_ScriptFullPath%,%Dir%\Backup\%NNE% %A_Now%.%Ext%
		FileAppend,%Info%,%A_ScriptFullPath%,UTF-8
		Reload
		ExitApp
	}else
		m("Unable to update.  Please try again later.")
}
Launch(){
	static KeyPress:=[]
	KeyPress.Push({Hotkey:A_ThisHotkey,time:A_Now A_MSec})
	SetTimer,CheckSpaceBetween,-500
	return
	CheckSpaceBetween:
	Order:=[]
	while(b:=KeyPress.Pop()){
		ThisHotkey:=b.Hotkey
		if(!IsObject(Obj:=Order[b.Hotkey]))
			Obj:=Order[b.Hotkey]:=[]
		Node:=xx.Find("//@hotkey",Format("{:T}",ThisHotkey))
		Obj.Push(Node)
	}for a,b in Order{
		if(b.MaxIndex()>1){
			All:=SN(b.1,"descendant::*")
			while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
				if(WinExist("ahk_id" ea.HWND))
					WinClose,% "ahk_id" ea.HWND
				b.1.RemoveAttribute("hwnd")
		}}else{
			CreateNew:
			Node:=b.1
			All:=SN(Node,"descendant::*")
			x:=y:=New:=0,WindowPosKeep:=[],Win:=[]
			while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
				Pos:=Monitors().List[ea.Window]
				Pos:=Pos?Pos:Monitors().List.1
				/*
					POS CAN BE THE EA OF THE MONITOR NODE THAT WE DECIDE IS THE RIGHT ONE
					IF THE EA.WINDOW IS AVAILABLE
						USE THAT
					ELSE
						USE THE ONE THAT IS THE DEFAULT OR LOOP BACKWARD UNTIL YOU GET TO A WINDOW?
				*/
				/*
					loop through the Mon:=ea.Window
						until you find a monitor that exists...
				*/
				if(!IsObject(Win[ea.Window])){
					Pos:=Monitors().List[ea.Window],Pos:=Pos?Pos:Monitors().List.1
					Win[ea.Window]:=[]
					for a,b in ["x","y","w","h"]{
						if(Win[ea.Window,b]="")
							Win[ea.Window,b]:=(b="x"?Pos.Left:b="y"?Pos.Top:0)
				}}
				if(aa.NodeName="Explorer"&&!WinExist("ahk_id" ea.HWND)){
					New:=1,GetWindows(1,"Explorer")
					Run,% "Explorer " ea.Folder
					while(!Current:=GetWindows(0,"Explorer")){
						Sleep,100
					}
					aa.SetAttribute("hwnd",Current)
					ID:=ahk_id%Current%
					WinHide,%ID%
					WinRestore,%ID%
				}else if(aa.NodeName="Window"&&ea.URL&&ea.EXE="Chrome.exe"&&!WinExist("ahk_id" SSN(aa,"@hwnd").text)){
					New:=1,GetWindows(1)
					if(!ea.Username||!ea.Password||!ea.UserNode||!ea.PassWordNode)
						Run,% "Chrome.exe --new-window " ea.URL,,Hide
					else{
						URLAfter:=1
						if(!FileExist("ChromeProfile"))
							FileCreateDir,ChromeProfile
						ChromeInst:=new Chrome("ChromeProfile")
					}
					while(!Current:=GetWindows())
						Sleep,100
					aa.SetAttribute("hwnd",Current)
					ID:=ahk_id%Current%
					WinHide,%ID%
					WinRestore,%ID%
				}ea:=XML.EA(aa),ID:="ahk_id" ea.HWND
				if(ea.max){
					WinGet,MinMax,MinMax,%ID%
					if(MinMax="-1"||New){
						Moved:=1
						WinRestore,%ID%
						WinGetPos,x,y,w,h,%ID%
						if(Abs(x-Pos.Left)>20||Abs(y-Pos.Top)>20){
							WinRestore,%ID%
							WinMove,%ID%,,% Pos.Left,% Pos.Top
						}
						WinWaitActive,%ID%,,4
						WinMaximize,%ID%
						WinActivate,%ID%
					}else{
						/*
							WinWait,%ID%
						*/
						WinMinimize,%ID%
				}}else if(ea.Width){
					if(Pos){
						Width:=Abs(Abs(Pos.Left)-Abs(Pos.Right)),Height:=Abs(Abs(Pos.Top)-Abs(Pos.Bottom))
						WinGet,MinMax,MinMax,%ID%
						if(MinMax=1||MinMax=-1){
							WinRestore,%ID%
							WinActivate,%ID%
							No:=1
						}NewWidth:=Floor(Width*ea.Width),NewHeight:=Floor(Height*ea.Height)
						WinGetPos,wx,wy,ww,wh,%ID%
						if(Win[ea.Window].X!=wx||Win[ea.Window].Y!=wy||NewWidth!=ww||NewHeight!=wh){
							Moved:=1
							WinMove,% "ahk_id" ea.HWND,,% Win[ea.Window].X,% Win[ea.Window].Y,% Width*ea.Width,% Height*ea.Height
						}if(ea.Width<1)
							Win[ea.Window].X+=Width*ea.Width
						if(ea.Height<1)
							Win[ea.Window].Y+=Height*ea.Height
					}
				}
				if(URLAfter){
					Login(aa,ChromeInst),URLAfter:=0
				}
			}if(!New&&!Moved&&Pos&&!No){
				while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
					WinMinimize,% "ahk_id" ea.HWND
			}
		}
	}return
}
class Chrome
{
	static DebugPort := 9222
	
	; Escape a string in a manner suitable for command line parameters
	CliEscape(Param)
	{
		return """" RegExReplace(Param, "(\\*)""", "$1$1\""") """"
	}
	
	__New(ProfilePath:="", URL:="about:blank", ChromePath:="", DebugPort:="")
	{
		if (ProfilePath != "" && !InStr(FileExist(ProfilePath), "D"))
			throw Exception("The given ProfilePath does not exist")
		this.ProfilePath := ProfilePath
		
		; TODO: Perform a more rigorous search for Chrome
		if (ChromePath == "")
			FileGetShortcut, %A_StartMenuCommon%\Programs\Google Chrome.lnk, ChromePath
		if !FileExist(ChromePath)
			throw Exception("Chrome could not be found")
		this.ChromePath := ChromePath
		
		if (DebugPort != "")
		{
			this.DebugPort := Round(DebugPort)
			if (this.DebugPort <= 0) ; TODO: Support DebugPort of 0
				throw Exception("DebugPort must be a positive integer")
		}
		
		; TODO: Support an array of URLs
		Run, % this.CliEscape(ChromePath)
		. " --remote-debugging-port=" this.DebugPort
		. (ProfilePath ? " --user-data-dir=" this.CliEscape(ProfilePath) : "")
		. (URL ? " " this.CliEscape(URL) : "")
	}
	
	GetTabs()
	{
		http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		http.open("GET", "http://127.0.0.1:" this.DebugPort "/json")
		http.send()
		return this.Jxon_Load(http.responseText)
	}
	
	GetTab(Index:=0)
	{
		; TODO: Filter pages by type before returning an indexed page
		if (Index > 0)
			return new this.Tab(this.GetTabs()[Index])
		
		for Index, Tab in this.GetTabs()
			if (Tab.type == "page")
				return new this.Tab(Tab)
	}
	
	class Tab
	{
		Connected := False
		ID := 0
		Responses := []
		
		__New(wsurl)
		{
			this.BoundKeepAlive := this.Call.Bind(this, "Browser.getVersion",, False)
			
			; TODO: Throw exception on invalid objects
			if IsObject(wsurl)
				wsurl := wsurl.webSocketDebuggerUrl
			
			wsurl := StrReplace(wsurl, "localhost", "127.0.0.1")
			this.ws := {"base": this.WebSocket, "_Event": this.Event, "Parent": this}
			this.ws.__New(wsurl)
			
			while !this.Connected
				Sleep, 50
		}
		
		Call(DomainAndMethod, Params:="", WaitForResponse:=True)
		{
			if !this.Connected
				throw Exception("Not connected to tab")
			
			; Use a temporary variable for ID in case more calls are made
			; before we receive a response.
			ID := this.ID += 1
			this.ws.Send(Chrome.Jxon_Dump({"id": ID
			, "method": DomainAndMethod, "params": Params}))
			
			if !WaitForResponse
				return
			
			; Wait for the response
			this.responses[ID] := False
			while !this.responses[ID]
				Sleep, 50
			
			; Get the response, check if it's an error
			response := this.responses.Delete(ID)
			if (response.error)
				throw Exception("Chrome indicated error in response",, Chrome.Jxon_Dump(response.error))
			
			return response.result
		}
		
		Evaluate(JS)
		{
			response := this.Call("Runtime.evaluate",
			( LTrim Join
			{
				"expression": JS,
				"objectGroup": "console",
				"includeCommandLineAPI": Chrome.Jxon_True(),
				"silent": Chrome.Jxon_False(),
				"returnByValue": Chrome.Jxon_False(),
				"userGesture": Chrome.Jxon_True(),
				"awaitPromise": Chrome.Jxon_False()
			}
			))
			
			if (response.exceptionDetails)
				throw Exception(response.result.description,, Chrome.Jxon_Dump(response.exceptionDetails))
			
			return response.result
		}
		
		WaitForLoad(DesiredState:="complete", Interval:=100)
		{
			while this.Evaluate("document.readyState").value != DesiredState
				Sleep, %Interval%
		}
		
		Event(EventName, Event)
		{
			; Called from WebSocket
			if this.Parent
				this := this.Parent
			
			; TODO: Handle Error events
			if (EventName == "Open")
			{
				this.Connected := True
				BoundKeepAlive := this.BoundKeepAlive
				SetTimer, %BoundKeepAlive%, 15000
			}
			else if (EventName == "Message")
			{
				data := Chrome.Jxon_Load(Event.data)
				if this.responses.HasKey(data.ID)
					this.responses[data.ID] := data
			}
			else if (EventName == "Close")
			{
				this.Disconnect()
			}
		}
		
		Disconnect()
		{
			if !this.Connected
				return
			
			this.Connected := False
			this.ws.Delete("Parent")
			this.ws.Disconnect()
			
			BoundKeepAlive := this.BoundKeepAlive
			SetTimer, %BoundKeepAlive%, Delete
			this.Delete("BoundKeepAlive")
		}
		
		class WebSocket
{
	__New(WS_URL)
	{
		static wb
		
		; Create an IE instance
		Gui, +hWndhOld
		Gui, New, +hWndhWnd
		this.hWnd := hWnd
		Gui, Add, ActiveX, vWB, Shell.Explorer
		Gui, %hOld%: Default
		
		; Write an appropriate document
		WB.Navigate("about:<!DOCTYPE html><meta http-equiv='X-UA-Compatible'"
		. "content='IE=edge'><body></body>")
		while (WB.ReadyState < 4)
			sleep, 50
		this.document := WB.document
		
		; Add our handlers to the JavaScript namespace
		this.document.parentWindow.ahk_savews := this._SaveWS.Bind(this)
		this.document.parentWindow.ahk_event := this._Event.Bind(this)
		this.document.parentWindow.ahk_ws_url := WS_URL
		
		; Add some JavaScript to the page to open a socket
		Script := this.document.createElement("script")
		Script.text := "ws = new WebSocket(ahk_ws_url);`n"
		. "ws.onopen = function(event){ ahk_event('Open', event); };`n"
		. "ws.onclose = function(event){ ahk_event('Close', event); };`n"
		. "ws.onerror = function(event){ ahk_event('Error', event); };`n"
		. "ws.onmessage = function(event){ ahk_event('Message', event); };"
		this.document.body.appendChild(Script)
	}
	
	; Called by the JS in response to WS events
	_Event(EventName, Event)
	{
		this["On" EventName](Event)
	}
	
	; Sends data through the WebSocket
	Send(Data)
	{
		this.document.parentWindow.ws.send(Data)
	}
	
	; Closes the WebSocket connection
	Close(Code:=1000, Reason:="")
	{
		this.document.parentWindow.ws.close(Code, Reason)
	}
	
	; Closes and deletes the WebSocket, removing
	; references so the class can be garbage collected
	Disconnect()
	{
		if this.hWnd
		{
			this.Close()
			Gui, % this.hWnd ": Destroy"
			this.hWnd := False
		}
	}
}
	}
	
	Jxon_Load(ByRef src, args*)
{
	static q := Chr(34)

	key := "", is_key := false
	stack := [ tree := [] ]
	is_arr := { (tree): 1 }
	next := q . "{[01234567890-tfn"
	pos := 0
	while ( (ch := SubStr(src, ++pos, 1)) != "" )
	{
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true)
		{
			ln := ObjLength(StrSplit(SubStr(src, 1, pos), "`n"))
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == q)       ? "Expecting object key enclosed in double quotes"
			  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Exception(msg, -1, ch)
		}

		is_array := is_arr[obj := stack[1]]

		if i := InStr("{[", ch)
		{
			val := (proto := args[i]) ? new proto : {}
			is_array? ObjPush(obj, val) : obj[key] := val
			ObjInsertAt(stack, 1, val)
			
			is_arr[val] := !(is_key := ch == "{")
			next := q . (is_key ? "}" : "{[]0123456789-tfn")
		}

		else if InStr("}]", ch)
		{
			ObjRemoveAt(stack, 1)
			next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
		}

		else if InStr(",:", ch)
		{
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q . "{[0123456789-tfn"
		}

		else ; string | number | true | false | null
		{
			if (ch == q) ; string
			{
				i := pos
				while i := InStr(src, q,, i+1)
				{
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					static end := A_AhkVersion<"2" ? 0 : -1
					if (SubStr(val, end) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				  val := StrReplace(val,    "\/",  "/")
				, val := StrReplace(val, "\" . q,    q)
				, val := StrReplace(val,    "\b", "`b")
				, val := StrReplace(val,    "\f", "`f")
				, val := StrReplace(val,    "\n", "`n")
				, val := StrReplace(val,    "\r", "`r")
				, val := StrReplace(val,    "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1)
				{
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					; \uXXXX - JSON unicode escape sequence
					xxxx := Abs("0x" . SubStr(val, i+2, 4))
					if (A_IsUnicode || xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}

				if is_key
				{
					key := val, next := ":"
					continue
				}
			}

			else ; number | true | false | null
			{
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
			
			; For numerical values, numerify integers and keep floats as is.
			; I'm not yet sure if I should numerify floats in v2.0-a ...
				static number := "number", integer := "integer"
				if val is %number%
				{
					if val is %integer%
						val += 0
				}
			; in v1.1, true,false,A_PtrSize,A_IsUnicode,A_Index,A_EventInfo,
			; SOMETIMES return strings due to certain optimizations. Since it
			; is just 'SOMETIMES', numerify to be consistent w/ v2.0-a
				else if (val == "true" || val == "false")
					val := %value% + 0
			; AHK_H has built-in null, can't do 'val := %value%' where value == "null"
			; as it would raise an exception in AHK_H(overriding built-in var)
				else if (val == "null")
					val := ""
			; any other values are invalid, continue to trigger error
				else if (pos--, next := "#")
					continue
				
				pos += i-1
			}
			
			is_array? ObjPush(obj, val) : obj[key] := val
			next := obj==tree ? "" : is_array ? ",]" : ",}"
		}
	}

	return tree[1]
}

Jxon_Dump(obj, indent:="", lvl:=1)
{
	static q := Chr(34)

	if IsObject(obj)
	{
		static Type := Func("Type")
		if Type ? (Type.Call(obj) != "Object") : (ObjGetCapacity(obj) == "")
			throw Exception("Object type not supported.", -1, Format("<Object at 0x{:p}>", &obj))

		prefix := SubStr(A_ThisFunc, 1, InStr(A_ThisFunc, ".",, 0))
		fn_t := prefix "Jxon_True",  obj_t := this ? %fn_t%(this) : %fn_t%()
		fn_f := prefix "Jxon_False", obj_f := this ? %fn_f%(this) : %fn_f%()

		if (&obj == &obj_t)
			return "true"
		else if (&obj == &obj_f)
			return "false"

		is_array := 0
		for k in obj
			is_array := k == A_Index
		until !is_array

		static integer := "integer"
		if indent is %integer%
		{
			if (indent < 0)
				throw Exception("Indent parameter must be a postive integer.", -1, indent)
			spaces := indent, indent := ""
			Loop % spaces
				indent .= " "
		}
		indt := ""
		Loop, % indent ? lvl : 0
			indt .= indent

		this_fn := this ? Func(A_ThisFunc).Bind(this) : A_ThisFunc
		lvl += 1, out := "" ; Make #Warn happy
		for k, v in obj
		{
			if IsObject(k) || (k == "")
				throw Exception("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", &obj) : "<blank>")
			
			if !is_array
				out .= ( ObjGetCapacity([k], 1) ? %this_fn%(k) : q . k . q ) ;// key
				    .  ( indent ? ": " : ":" ) ; token + padding
			out .= %this_fn%(v, indent, lvl) ; value
			    .  ( indent ? ",`n" . indt : "," ) ; token + indent
		}

		if (out != "")
		{
			out := Trim(out, ",`n" . indent)
			if (indent != "")
				out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
		}
		
		return is_array ? "[" . out . "]" : "{" . out . "}"
	}

	; Number
	else if (ObjGetCapacity([obj], 1) == "")
		return obj

	; String (null -> not supported by AHK)
	if (obj != "")
	{
		  obj := StrReplace(obj,  "\",    "\\")
		, obj := StrReplace(obj,  "/",    "\/")
		, obj := StrReplace(obj,    q, "\" . q)
		, obj := StrReplace(obj, "`b",    "\b")
		, obj := StrReplace(obj, "`f",    "\f")
		, obj := StrReplace(obj, "`n",    "\n")
		, obj := StrReplace(obj, "`r",    "\r")
		, obj := StrReplace(obj, "`t",    "\t")

		static needle := (A_AhkVersion<"2" ? "O)" : "") . "[^\x20-\x7e]"
		while RegExMatch(obj, needle, m)
			obj := StrReplace(obj, m[0], Format("\u{:04X}", Ord(m[0])))
	}
	
	return q . obj . q
}

Jxon_True()
{
	static obj := {}
	return obj
}

Jxon_False()
{
	static obj := {}
	return obj
}
}


^j::
ChromeInst:=new Chrome("ChromeProfile")
FileCreateDir, ChromeProfile
Tab:=ChromeInst.GetTab()
Tab.Call("Page.navigate",{"url":"https://cloud.digitalocean.com/login"})
Tab.WaitForLoad()
RootNode := Tab.Call("DOM.getDocument").root
Tab.Evaluate("document.querySelector('input[type=submit]').click();")
return


Login(Node,ChromeInst){
	FileCreateDir, ChromeProfile
	Tab:=ChromeInst.GetTab(),ea:=XML.EA(Node),Tab.Call("Page.navigate",{"url":ea.URL})
	Tab.WaitForLoad()
	RootNode:=Tab.Call("DOM.getDocument").root
	for a,b in ea
		List.=a " = " b "`n"
	if(ea.Username&&ea.Usernode){
		User:=ea.IDUser?"id=":ea.NameUser?"name=":ea.TypeUser?"type=":""
		NameNode:=Tab.Call("DOM.querySelector",{"nodeId":RootNode.nodeId,"selector":"input[" User ea.UserNode "]"})
		Tab.Call("DOM.setAttributeValue",{"nodeId":NameNode.NodeId,"name":"value","value":ea.UserName})
		DoClick:=1
	}if(ea.PassWordNode&&ea.Password){
		Pass:=ea.IDPass?"id=":ea.NamePass?"name=":ea.TypePass?"type=":""
		NameNode:=Tab.Call("DOM.querySelector",{"nodeId":RootNode.nodeId,"selector":"input[" Pass ea.PassWordNode "]"})
		Tab.Call("DOM.setAttributeValue",{"nodeId":NameNode.NodeId,"name":"value","value":ea.PassWord})
		DoClick:=1
	}if(DoClick){
		Tab.Evaluate("document.querySelector('input[" (ea.NameSub?"name=":ea.IDSub?"id=":"type=") (ea.SubmitID?ea.SubmitID:"submit") "]').click();")
	}
}
CreatePassWordSequence(){
	InputBox,Keys,Number Of Keys,Enter the number of keys that you want to have in this sequence,,,,,,,,4
	if(ErrorLevel||Keys~="\D")
		return
	Top:=xx.Add("PassWord",,,1),ClearLast()
	Loop,%Keys%
		Last:=xx.Under(Top,"Key",(A_Index=1?{last:1}:""))
	PopulateSpaces()
}
Enter(){
	static HotKey,InputHotkey,Node,Password,InputHotkeyHWND
	ControlGetFocus,Focus,% v.ID
	KeyWait,Enter,U
	if(Focus="SysTreeView321"){
		Node:=xx.SSN("//*[@tv='" TV_GetSelection() "']")
		if(Node.NodeName="Window"){
			CreateChrome(Node)
		}else if(Node.NodeName="Key"||Node.NodeName="HotKey"){
			for a,b in v.CurrentHotkeys{
				Try
					Hotkey,%a%,Off
			}
			Gui,3:Destroy
			Gui,3:Default
			Gui,Color,0,0
			Gui,Font,c0xAAAAAA
			Gui,Add,Text,,Hotkey Field:
			Gui,Add,Hotkey,vHotkey w200 gSetOnlyHotkey Limit1,% SSN(Node,"@hotkey").text
			Gui,Add,Text,,Manual Hotkey:
			Hotkey:=SSN(Node,"@hotkey").text
			Gui,Add,Edit,gKeyEditHotkey vInputHotkey hwndInputHotkeyHWND w200,% (Hotkey~="i)F[13-24]"?Hotkey:"")
			if(Password:=SSN(Node,"@password").text){
				Gui,Add,Text,,Password:
				Gui,Add,Edit,vPassWord w200 Password,% Decode(Password)
			}
			Gui,Add,Button,gSaveKey Default,Save HotKey
			Gui,Show
			return
			SetOnlyHotkey:
			Gui,3:Submit,Nohide
			ControlSetText,,%Hotkey%,ahk_id%InputHotkeyHWND%
			return
			SaveKey:
			Gui,3:Submit,Nohide
			Hotkey:=InputHotkey?InputHotkey:HotKey
			Try{
				Hotkey,%HotKey%,DeadEnd,On
				Hotkey,%HotKey%,DeadEnd,Off
			}Catch
				return
			Hotkey:=Format("{:T}",Hotkey),Exist:=Format("{:T}",Hotkey),Exist:=xx.SSN("//*[@hotkey='" Hotkey "']")
			if(Password)
				Node.SetAttribute("password",Encode(Password))
			if(Exist.xml=Node.xml){
				Gui,3:Destroy
				return PopulateSpaces(1)
			}if(Exist)
				return m("Duplicate Hotkey")
			else
				Node.SetAttribute("hotkey",Hotkey)
			PopulateSpaces(1)
			Gui,3:Destroy
			return
			3GuiEscape:
			Gui,3:Destroy
			return
			KeyEditHotkey:
			Gui,3:Submit,Nohide
			GuiControl,3:,msctls_hotkey321,%InputHotkey%
			return
		}else if(Node.NodeName="Explorer"){
			CreateExplorerWindow(Node)
		}
	}return
	ButtonOK:
	Enter()
	return
}
DeadEnd(){
}
+Escape::
Exit:
All:=xx.SN("//*[@hwnd]")
xx.Transform(2)
while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
	aa.RemoveAttribute("hwnd")
	if(SSN(aa,"ancestor::HotKey")){
		if(WinExist("ahk_id" ea.HWND))
			WinClose,% "ahk_id" ea.HWND
	}
}All:=xx.SN("//*[@entered]")
while(aa:=All.Item[A_Index-1])
	aa.RemoveAttribute("entered")
Node:=xx.SSN("//Exist"),Node.ParentNode.RemoveChild(Node),All:=xx.SN("//*[@last]")
while(aa:=All.Item[A_Index-1])
	aa.RemoveAttribute("last")
xx.SSN("//*[@tv='" TV_GetSelection() "']").SetAttribute("last",1)
xx.Save(1)
ExitApp
return
ClearLast(){
	All:=xx.SN("//*[@last]")
	while(aa:=All.Item[A_Index-1])
		aa.RemoveAttribute("last")
}
Delete(){
	ControlGetFocus,Focus,% v.ID
	if(Focus="SysTreeView321"){
		Node:=xx.SSN("//*[@tv='" TV_GetSelection() "']")
		if(m("Can Not Be Undone!`nDelete " Node.xml "?","ico:!","btn:ync","def:2")="Yes"){
			ClearLast(),Next:=Node.NextSibling?Node.NextSibling:Node.PreviousSibling?Node.PreviousSibling:Node.ParentNode,Node.ParentNode.RemoveChild(Node),Next.SetAttribute("last",1),PopulateSpaces()
		}
	}
}
Convert_Hotkey(key){
	if(!Key)
		return "Undefined"
	StringUpper,key,key
	for a,b in [{Ctrl:"^"},{Win:"#"},{Alt:"!"},{Shift:"+"}]
		for c,d in b
			if(InStr(key,d))
				build.=c "+",key:=RegExReplace(key,"\" d)
	return build key
}
PassWordInput(){
	Node:=xx.SSN("//*[@hotkey='" A_ThisHotkey "']")
	All:=SN(Node,"preceding-sibling::*")
	if(SSN(Node,"@entered"))
		Failed:=1
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		if(!ea.Entered){
			Failed:=1
			Break
		}
	}if(!Node.NextSibling&&Node.xml){
		All:=SN(Node.ParentNode,"descendant::*")
		Node.SetAttribute("entered",1)
		while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
			if(!ea.Entered)
				Failed:=1
			aa.RemoveAttribute("entered")
		}
		if(Failed){
			All:=SN(Node.ParentNode,"descendant::*")
			while(aa:=All.Item[A_Index-1]){
				aa.RemoveAttribute("entered")
			}
			return Show?m("Sequence Failed"):""
		}
		if(!Password:=SSN(Node,"@password").text){
			InputBox,Password,Password,Enter the password for this sequence
			if(ErrorLevel||!Password)
				return
			return Node.SetAttribute("password",Encode(Password))
		}Clip:=ClipboardAll,Clipboard:=Decode(Password)
		Node.RemoveAttribute("entered")
		while(Clipboard!=Decode(Password))
			Sleep,50
		Sleep,100
		Send,^v
		Sleep,100
		Clipboard:=Clip
		Send,{Enter}
		return
	}
	if(Failed){
		All:=SN(Node.ParentNode,"descendant::*")
		while(aa:=All.Item[A_Index-1]){
			aa.RemoveAttribute("entered")
		}
		return Show?m("Sequence Failed"):""
	}else
		Node.SetAttribute("entered",1)
}
CreateChrome(EditNode:=""){
	static
	if(EditNode.NodeName){
		Node:=EditNode
		if(Node.NodeName="Hotkey"){
			InputBox,Key,New Key,Enter the key for this item`n! = Alt`n^ = Control`n+ = Shift`n# = Windows Key`nExample: Ctrl+Alt+F1 = ^!F1,,,200,,,,,% SSN(Node,"@hotkey").text
			if(!ErrorLevel)
				CheckHotkey(Node,Key)
			return
		}
	}
	ClearLast()
	All:=xx.SN("//*[@hotkey]")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		Try
			Hotkey,% ea.Hotkey,Off
	}
	NewWin:=new GUIKeep("CreateChrome")
	for a,b in [["url","Enter URL",ea.URL],["window","Enter the window number to display this on",ea.Window?ea.Window:1]]{
		NewWin.Add("Text,," b.2 ":","Edit,w200 v" b.1 (A_Index=2?" Number":"") "," b.3)
	}
	NewWin.Add("Text,,Typed Hotkey: (Press the keys)","Hotkey,w200 vHotkey gSetManual Limit1," SSN(Node,"ancestor-or-self::HotKey/@hotkey").text,"Text,,Manual Hotkey:","Edit,w200 vManual gManualHotkey hwndManualHWND," SSN(Node,"ancestor-or-self::HotKey/@hotkey").text
			,"Text,,User Name:"
			,"Edit,vusername w200"
			,"Text,,User Attribute:"
			,"Edit,vusernode w200"
			,"Radio,viduser Checked,id"
			,"Radio,x+M vtypeuser,type"
			,"Radio,x+M vnameuser,name"
			,"Text,xm,Password:"
			,"Edit,vpassword w200"
			,"Text,,Password Attribute:"
			,"Edit,vpasswordnode w200"
			,"Radio,vidpass Checked,id"
			,"Radio,x+M vtypepass,type"
			,"Radio,x+M vnamepass,name"
			,"Text,xm,Submit ID (Usually submit:type)"
			,"Edit,w200 vsubmitid,submit"
			,"Radio,vtypesub Checked,type"
			,"Radio,x+M vidsub,id"
			,"Radio,x+M vnamesub,name"
			,"Button,xm gCCGo Default,Go")
	for a,b in XML.EA(Node)
		NewWin.SetText(a,b)
	NewWin.Show("Flan")
	;here
	return
	CCGo:
	Obj:=NewWin[]
	for a,b in Obj
		Node.SetAttribute(a,b)
	NewWin.Exit()
	PopulateSpaces(),Node:=""
	return
	SetManual:
	Gui,2:Submit,Nohide
	ControlSetText,,%Hotkey%,ahk_id%ManualHWND%
	return
	ManualHotkey:
	Gui,2:Submit,Nohide
	GuiControl,2:,msctls_Hotkey321,%Manual%
	return
	2GuiEscape:
	Gui,2:Destroy
	return
}
CheckHotkey(Node,Key){
	Exist:=xx.SSN("//*[@hotkey='" Format("{:T}",Key) "']")
	if(Exist.xml=Node.xml)
		return 1
	if(!Exist){
		Node.SetAttribute("hotkey",Format("{:T}",Key))
		return 1
	}else
		return 0,m("Hotkey Exists")
}
GetWindowPositions(){
	SysGet,Monitors,MonitorCount
	SysGet,Main,MonitorPrimary
	Loop,%Monitors%{
		SysGet,Mon,MonitorWorkArea,%A_Index%
		/*
			DebugWindow("Top: " MonTop " - Left: " MonLeft " - Right: " MonRight " - Bottom: " MonBottom "`n")
		*/
	}
	Loop,%Monitors%{
		SysGet,Mon,MonitorWorkArea,%A_Index%
		if(xx.SSN("//Monitor[" A_Index "][@main]")&&A_Index!=Main){
			Alert:=1
			Break
		}
		if(!xx.SSN("//*[@left='" MonLeft "' and @top='" MonTop "']")){
			Alert:=1
			Break
		}
	}if(Alert){
		Top:=xx.ReCreate("//Monitors","Monitors")
		Loop,%Monitors%{
			SysGet,Mon,MonitorWorkArea,%A_Index%
			Node:=xx.Add("Monitors/Monitor",{left:MonLeft,top:MonTop,right:MonRight,bottom:MonBottom},,1)
			if(A_Index=Main)
				Node.SetAttribute("main",1)
		}
		Gui(1)
	}
	/*
		DebugWindow("`n")
	*/
}
CreateExplorerWindow(SentNode:=""){
	static
	Node:=SentNode
	ClearLast()
	All:=xx.SN("//*[@hotkey]")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		Try
			Hotkey,% ea.Hotkey,Off
	}
	Gui,2:Destroy
	Gui,2:Default
	Gui,Color,0,0
	Gui,Font,c0xAAAAAA
	ea:=XML.EA(Node)
	Gui,Add,Text,,Width and Height values:`n`t1=Full Width/Height`n`t.5=Half Width/Height`n`t(Both values Blank for FullScreen)
	for a,b in [["folder","Enter Folder",ea.Folder],["window","Enter the window number to display this on",ea.Window?ea.Window:1]]{
		Gui,Add,Text,,% b.2 ":"
		Gui,Add,Edit,% "w200 v" b.1,% b.3
	}
	Gui,Add,Text,,Typed Hotkey: (Press the keys)
	Gui,Add,Hotkey,w200 vHotkey gSetExpManual,% SSN(Node,"ancestor-or-self::HotKey/@hotkey").text
	Gui,Add,Text,,Manual Hotkey:
	Gui,Add,Edit,w200 vManual gManualHotkey1 hwndExpMan
	for a,b in [["width","Enter the Width",ea.Width],["height","Enter the Height",ea.Height]]{
		Gui,Add,Text,,% b.2 ":"
		Gui,Add,Edit,% "w200 v" b.1 (A_Index=3?" Password":""),% b.3
	}
	Gui,Add,Button,gSaveChrome1 Default,&Save
	Gui,show,,Chrome
	return
	SetExpManual:
	Gui,2:Submit,Nohide
	ControlSetText,,%Hotkey%,ahk_id%ExpMan%
	return
	ManualHotkey1:
	Gui,2:Submit,Nohide
	GuiControl,2:,msctls_Hotkey321,%Manual%
	return
	SaveChrome1:
	Gui,2:Submit,Nohide
	if(Manual){
		Try{
			Hotkey,%Manual%,DeadEnd,On
			Hotkey:=Manual
		}
	}else
		Hotkey:=Hotkey
	ClearLast()
	Obj:={folder:Folder,window:Window,last:1}
	if(Width&&Height)
		Obj.width:=Width,Obj.height:=Height,Node.RemoveAttribute("max")
	else
		Obj.max:=1
	if(Node.XML)
		for a,b in Obj
			Node.SetAttribute(a,b)
	else
		New:=xx.Add("WorkSpaces/HotKey",,,1),Node:=xx.Under(New,"Explorer")
	for a,b in Obj
		Node.SetAttribute(a,b)
	if(CheckHotkey(SSN(Node,"ancestor-or-self::HotKey"),Hotkey)){
		Gui,2:Destroy
		Node:="",xx.Save(1)
	}
	PopulateSpaces()
	return
}
Explorer(){
	Node:=xx.SSN("//*[@hotkey='" A_ThisHotkey "']")
	m(Node.xml)
}
MainTV(){
	if(A_GuiEvent="K"){
		if(A_EventInfo="46")
			return Delete()
	}else
		return ;t(A_EventInfo,A_GuiEvent)
}
AddExplorerWindow(){
	Default(),Node:=xx.SSN("//*[@tv='" TV_GetSelection() "']/ancestor-or-self::HotKey")
	if(Node.NodeName!="HotKey")
		return m("Please select a hotkey to add an explorer window to")
	CreateExplorerWindow(xx.Under(Node,"Explorer"))
}
AddChromeWindow(){
	Default(),Node:=xx.SSN("//*[@tv='" TV_GetSelection() "']/ancestor-or-self::HotKey")
	if(Node.NodeName!="HotKey")
		return m("Please select a hotkey to add an explorer window to")
	CreateChrome(xx.Under(Node,"Window"))
}
Default(Control:="SysTreeView321",Win:=1){
	Gui,%Win%:Default
	Type:=InStr(Control,"TreeView")?"TreeView":"ListView"
	Gui,%Win%:%Type%,%Control%
}
class GUIKeep{
	static table:=[],showlist:=[]
	__Get(x*){
		if(x.1)
			return this.Var[x.1]
		return this.Add()
	}__New(win,parent:=""){
		DetectHiddenWindows,On
		Gui,%win%:Destroy
		Gui,%win%:+hwndhwnd -DPIScale
		Gui,%win%:Margin,5,5
		Gui,%win%:Font,c0xAAAAAA
		Gui,%win%:Color,0,0
		this.All:=[],this.gui:=[],this.hwnd:=hwnd,this.con:=[],this.XML:=new XML("GUI"),this.ahkid:=this.id:="ahk_id" hwnd,this.win:=win,this.Table[win]:=this,this.var:=[],this.Radio:=[],this.Static:=[]
		for a,b in {border:A_OSVersion~="^10"?3:0,caption:DllCall("GetSystemMetrics",int,4,"int")}
			this[a]:=b
		Gui,%win%:+LabelGUIKeep.
		Gui,%win%:Default
		return this
	}Add(info*){
		static
		if(!info.1){
			var:=[]
			Gui,% this.Win ":Submit",Nohide
			for a,b in this.var{
				if(b.Type="s")
					Var[a]:=b.sc.GetUNI()
				else
					var[a]:=%a%
			}return var
		}for a,b in info{
			i:=StrSplit(b,","),newpos:=""
			if(i.1="ComboBox")
				WinGet,ControlList,ControlList,% this.ID
			if(i.1="s"){
				Pos:=RegExReplace(i.2,"OU)\s*\b(v.+)\b")
				sc:=new s(1,{Pos:Pos}),hwnd:=sc.sc
			}else
				Gui,% this.win ":Add",% i.1,% i.2 " hwndhwnd",% i.3
			if(RegExMatch(i.2,"U)\bg(.*)\b",Label))
				Label:=Label1
			if(RegExMatch(i.2,"U)\bv(.*)\b",var))
				this.var[var1]:={hwnd:HWND,type:i.1,sc:sc}
			this.con[hwnd]:=[]
			if(i.4!="")
				this.con[hwnd,"pos"]:=i.4,this.resize:=1
			if(i.5)
				this.Static.Push(hwnd)
			Name:=Var1?Var1:Label
			if(i.1="ListView"||i.1="TreeView")
				this.All[Name]:={HWND:HWND,Name:Name,Type:i.1,ID:"ahk_id" HWND}
			if(i.1="ComboBox"){
				WinGet,ControlList2,ControlList,% this.ID
				Obj:=StrSplit(ControlList2,"`n"),LeftOver:=[]
				for a,b in Obj
					LeftOver[b]:=1
				for a,b in Obj2:=StrSplit(ControlList,"`n")
					LeftOver.Delete(b)
				for a in LeftOver{
					if(!InStr(a,"ComboBox")){
						ControlGet,Married,HWND,,%a%,% this.ID
						this.XML.Add("Control",{hwnd:Married,id:"ahk_id" Married+0,name:Name,type:"Edit"},,1)
					}
				}
				
			}
			this.XML.Add("Control",{hwnd:HWND,id:"ahk_id" HWND,name:Name,type:i.1},,1)
	}}Close(a:=""){
		/*
			this:=GUIKeep.table[A_Gui]
			if(A_Gui=1)
				Exit()
		*/
	}ContextMenu(x*){
		if(IsFunc(Function:=A_Gui "GuiContextMenu"))
			%Function%(x*)
	}Current(XPath,Number){
		Node:=Settings.SSN(XPath)
		all:=SN(Node.ParentNode,"*")
		while(aa:=all.item[A_Index-1])
			(A_Index=Number?aa.SetAttribute("last",1):aa.RemoveAttribute("last"))
	}Default(Name:=""){
		Gui,% this.Win ":Default"
		ea:=this.XML.EA("//Control[@name='" Name "']")
		if(ea.Type~="TreeView|ListView")
			Gui,% this.Win ":" ea.Type,% ea.HWND
	}DisableAll(){
		for a,b in this.All{
			GuiControl,1:+g,% b.HWND
			GuiControl,1:-Redraw,% b.HWND
		}
	}DropFiles(filelist,ctrl,x,y){
		df:="DropFiles"
		if(IsFunc(df))
			%df%(filelist,ctrl,x,y)
	}EnableAll(){
		for a,b in this.All{
			GuiControl,% this.Win ":+g" b.Name,% b.HWND
			GuiControl,% this.Win ":+Redraw",% b.HWND
		}
	}Escape(){
		KeyWait,Escape,U
		if(A_Gui!=1)
			Gui,%A_Gui%:Destroy
		return 
	}Exit(){
		Info:=MainWin[]
		Default(),Index1:=LV_GetNext(),Default("ShowCampaign"),Index2=LV_GetNext()
		Settings.Add("Last",{tab:Info.Tab,SysListView321:Index1,SysListView322:Index2})
		if(A_Gui=1){
			MainWin.SavePos()
			Settings.Save(1)
			ExitApp
		}else
			Gui,% this.Win ":Destroy"
		return
	}Focus(Control){
		this.Default(Control)
		ControlFocus,,% this.GetCtrlXML(Control,"id")
	}GetCtrl(Name,Value:="hwnd"){
		return this.All[Name]
	}GetCtrlXML(Name,Value:="hwnd"){
		return Info:=this.XML.SSN("//*[@name='" Name "']/@" Value).text
	}GetPos(){
		Gui,% this.win ":Show",AutoSize Hide
		WinGet,cl,ControlListHWND,% this.ahkid
		pos:=this.winpos(),ww:=pos.w,wh:=pos.h,flip:={x:"ww",y:"wh"}
		for index,hwnd in StrSplit(cl,"`n"){
			obj:=this.gui[hwnd]:=[]
			ControlGetPos,x,y,w,h,,ahk_id%hwnd%
			for c,d in StrSplit(this.con[hwnd].pos)
				d~="w|h"?(obj[d]:=%d%-w%d%):d~="x|y"?(obj[d]:=%d%-(d="y"?wh+this.Caption+this.Border:ww+this.Border))
		}
		Gui,% this.win ":+MinSize800x665"
	}Map(Location,Info:=""){
		static Map:={PopulateAccounts:["PopulateAccounts"],PopulateAllFilters:["PopulateMGList"],PopulateMGList:["PopulateMGList"]
				  ,PopulateMGListItems:["PopulateMGListItems"],PopulateMGTags:["PopulateMGTags"],PopulateMGMessages:["PopulateMGMessages"]}
		if(!Map[Location])
			return m("Working on: " Location,ExtraInfo.1,ExtraInfo.2)
		this.DisableAll()
		for a,b in Map[Location]{
			if(b.1="Fix")
				return m("Work On: " a)
			MainWin.Busy:=1,MainWin.Function:=b.1?b.1:b
			Info:=%b%(Info)
			if(Info.tv){
				TV_Modify(Info.tv,"Select Vis Focus")
			}
			while(MainWin.Busy){
				t("It's busy",A_TickCount,MainWin.Function,"Hmm.")
			}
		}this.EnableAll()
		return Info
	}SavePos(){
		if(!top:=Settings.SSN("//gui/position[@window='" this.win "']"))
			top:=Settings.Add("gui/position",{window:this.Win},,1)
		top.text:=this.WinPos().text
	}SetText(Control,Text:=""){
		if((sc:=this.Var[Control].sc).sc){
			Len:=VarSetCapacity(tt,StrPut(Text,"UTF-8")-1)
			/*
				m(Text)
			*/
			/*
				Sleep,500
			*/
			/*
				m(sc.2137)
			*/
			StrPut(Text,&tt,Len,"UTF-8")
			sc.2181(0,&tt)
		}else{
			GuiControl,% this.Win ":",% this.GetCtrlXML(Control),%Text%
		}
	}Show(name){
		this.GetPos(),Pos:=this.Resize=1?"":"AutoSize",this.name:=name
		if(this.resize=1)
			Gui,% this.win ":+Resize"
		GUIKeep.showlist.push(this)
		SetTimer,guikeepshow,-100
		return
		GUIKeepShow:
		while(this:=GUIKeep.Showlist.Pop()){
			Gui,% this.win ":Show",% Settings.SSN("//gui/position[@window='" this.win "']").text " " pos,% this.name
			this.size()
			if(this.resize!=1){
				Gui,% this.win ":Show",AutoSize
			}
			WinActivate,% this.id
		}
		return
	}Size(){
		this:=GUIKeep.table[A_Gui],pos:=this.winpos()
		for a,b in this.gui
			for c,d in b
				GuiControl,% this.win ":MoveDraw",%a%,% c (c~="y|h"?pos.h:pos.w)+d
	}WinPos(HWND:=0){
		VarSetCapacity(rect,16),DllCall("GetClientRect",ptr,(HWND?HWND:this.hwnd),ptr,&rect)
		WinGetPos,x,y,,,% (HWND?"ahk_id" HWND:this.ahkid)
		w:=NumGet(rect,8,"int"),h:=NumGet(rect,12,"int"),text:=(x!=""&&y!=""&&w!=""&&h!="")?"x" x " y" y " w" w " h" h:""
		return {x:x,y:y,w:w,h:h,text:text}
	}
}
t(x*){
	for a,b in x{
		if((obj:=StrSplit(b,":")).1="time"){
			SetTimer,killtip,% "-" obj.2*1000
			Continue
		}
		list.=b "`n"
	}
	Tooltip,% list
	return
	killtip:
	ToolTip
	return
}