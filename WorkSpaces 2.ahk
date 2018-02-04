#SingleInstance,Force
IDS:=[],Hotkey:=[],MyWindows:=[]
global xx:=New XML("Settings")
Gui()
GetWindows(1)
OnExit,Exit
List:=Monitors()
All:=xx.SN("//HotKey")
while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
	Hotkey,% ea.HotKey,Launch,On
}
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
Escape::
Exit:
All:=xx.SN("//Window[@hwnd]")
while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
	aa.RemoveAttribute("hwnd")
	WinClose,% "ahk_id" ea.HWND
}
Node:=xx.SSN("//Exist")
Node.ParentNode.RemoveChild(Node)
xx.Save(1)
ExitApp
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
		Node:=xx.Find("//@hotkey",ThisHotkey)
		Obj.Push(Node)
	}for a,b in Order{
		if(b.MaxIndex()>1){
			All:=SN(b.1,"descendant::Window")
			while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
				if(WinExist("ahk_id" ea.HWND))
					WinClose,% "ahk_id" ea.HWND
				b.1.RemoveAttribute("hwnd")
		}}else{
			CreateNew:
			Node:=b.1
			All:=SN(Node,"descendant::Window")
			x:=y:=New:=0,WindowPosKeep:=[],Win:=[]
			while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
				Pos:=Monitors().List[ea.Window]
				Pos:=Pos?Pos:Monitors().List.1
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
				if(ea.URL&&ea.EXE="Chrome.exe"&&!WinExist("ahk_id" SSN(aa,"@hwnd").text)){
					New:=1,GetWindows(1)
					Run,% "Chrome.exe --new-window " ea.URL,,Hide
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
						WinMaximize,%ID%
						WinActivate,%ID%
					}else
						WinMinimize,%ID%
				}else if(ea.Width){
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
			}if(!New&&!Moved&&Pos&&!No){
				while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
					WinMinimize,% "ahk_id" ea.HWND
			}
		}
	}return
}
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
	}
}
return
m(x*){
	static list:={btn:{oc:1,ari:2,ync:3,yn:4,rc:5,ctc:6},ico:{"x":16,"?":32,"!":48,"i":64}},msg:=[]
	list.title:="AHK Studio",list.def:=0,list.time:=0,value:=0,txt:=""
	for a,b in x
		obj:=StrSplit(b,":"),(vv:=List[obj.1,obj.2])?(value+=vv):(list[obj.1]!="")?(List[obj.1]:=obj.2):txt.=b "`n"
	msg:={option:value+262144+(list.def?(list.def-1)*256:0),title:list.title,time:list.time,txt:txt}
	Sleep,120
	MsgBox,% msg.option,% msg.title,% msg.txt,% msg.time
	for a,b in {OK:value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
		IfMsgBox,%a%
			return b
}
GetWindows(CreateList:=0){
	static WindowList:=[]
	WinGet,ID,list,ahk_exe Chrome.exe
	Loop,%ID%{
		HWND:=ID%A_Index%,HWND:=HWND+0
		WinGetTitle,Title,ahk_id%HWND%
		if(SubStr(Title,-12)="Google Chrome"){
			if(CreateList)
				xx.Add("Exist/HWND",{hwnd:hwnd},,1)
			if(!CreateList&&!xx.SSN("//*[@hwnd='" HWND "']"))
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
Gui(){
	Gui,Color,0,0
	Gui,Font,c0xAAAAAA
	Gui,Add,TreeView,w500 h500
	FileRead,ChangeLog,Lib\master ChangeLog.txt
	RegExMatch(ChangeLog,"OU)\x22message\x22:\x22(.*)\x22,",Info)
	Gui,Add,Edit,x+M w200 h500,% "Version Information:`r`n" RegExReplace(Info.1,"\\r\\n","`r`n")
	Gui,Add,Button,xm gCheckForUpdate,Check For Update
	Gui,Add,Button,xm gUpdateScript,Update Script
	Gui,Show,,WorkSpaces 2
	PopulateSpaces()
	return
}
PopulateSpaces(){
	All:=xx.SN("//descendant-or-self::*")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		if(ea.HotKey)
			aa.SetAttribute("tv",TV_Add(ea.HotKey,SSN(aa.ParentNode,"@tv").text))
		else if(aa.NodeName="Window"){
			aa.SetAttribute("tv",TV_Add("Chrome - " ea.URL,SSN(aa.ParentNode,"@tv").text))
		}
	}
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
	static DownloadURL:="http://raw.githubusercontent.com/maestrith/WorkSpaces-2/$1/WorkSpaces%202.AHK"
	Branch:="master"
	Info:=URLDownloadToVar(RegExReplace("https://raw.githubusercontent.com/maestrith/WorkSpaces-2/master/WorkSpaces%202.ahk","\$1",Branch))
	if(InStr(Info,"Look For This Text")){
		SplitPath,A_ScriptFullPath,,Dir,Ext,NNE
		FileMove,%A_ScriptFullPath%,%Dir%\%NNE% %A_Now%.%Ext%
		FileAppend,%Info%,%A_ScriptFullPath%,UTF-8
		Reload
		ExitApp
	}else
		m("Unable to update.  Please try again later.")
	/*
		https://raw.githubusercontent.com/maestrith/WorkSpaces-2/master/WorkSpaces%202.ahk
	*/
}