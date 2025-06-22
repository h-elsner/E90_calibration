        {********************************************************}
        {                                                        }
        {       Read and send data to Yuneec CGO3+ camera        }
        {                                                        }
        {       Copyright (c) 2025         Helmut Elsner         }
        {                                                        }
        {       Compiler: FPC 3.2.3   /    Lazarus 3.7           }
        {                                                        }
        { Pascal programmers tend to plan ahead, they think      }
        { before they type. We type a lot because of Pascal      }
        { verboseness, but usually our code is right from the    }
        { start. We end up typing less because we fix less bugs. }
        {           [Jorge Aldo G. de F. Junior]                 }
        {********************************************************}

(*
This source is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your option)
any later version.

This code is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

A copy of the GNU General Public License is available on the World Wide Web
at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
Boston, MA 02110-1335, USA.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*******************************************************************************)

{This unit needs following additional components:
- Synapse

Also the units mav_def and mav_msg from repository "Common units" are needed:
https://github.com/h-elsner/common_units
The unit msg57 is a dummy for Yuneec NFZ license procedure,
which is not open source.

2025-06-18 V1.1 Current removed. No useful values
}

unit E90read_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  lclintf, lcltype, Buttons, ActnList, Process, XMLPropStorage, ComCtrls, Grids,
  Menus, synaser, mav_def, mav_msg, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    acConnect: TAction;
    acClose: TAction;
    acDisconnect: TAction;
    acScanPorts: TAction;
    acDeleteText: TAction;
    acSaveText: TAction;
    ActionList1: TActionList;
    btnVersion: TButton;
    btnTempErs: TButton;
    btnZeroPhaseCali: TButton;
    btnYawEncCali: TButton;
    btnAccCali: TButton;
    btnZeroPhaseErs: TButton;
    btnAccErase: TButton;
    btnYawEncErs: TButton;
    btnPreFrontCali: TButton;
    btnDisconnect: TBitBtn;
    btnClose: TBitBtn;
    btnConnect: TBitBtn;
    btnFrontCali: TButton;
    btnFrontErs: TButton;
    btnReboot: TButton;
    btnTempCali: TButton;
    btnMotorTest: TButton;
    btnVibration: TButton;
    cbPort: TComboBox;
    cbRecord: TCheckBox;
    cbSpeed: TComboBox;
    GIMBALtext: TMemo;
    Image1: TImage;
    ImageList1: TImageList;
    gridPower: TStringGrid;
    Label1: TLabel;
    lblTempCali: TLabel;
    lblWarning: TLabel;
    lblPowerCycle: TLabel;
    lblGimbalBootTime: TLabel;
    lblBootTime: TLabel;
    mnClear: TMenuItem;
    mnSaveText: TMenuItem;
    Separator1: TMenuItem;
    mnPorts: TMenuItem;
    panelTempCali: TPanel;
    pcMain: TPageControl;
    panelRight: TPanel;
    panelYGCTop: TPanel;
    mnText: TPopupMenu;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    timerE90Command: TTimer;
    timerE90Heartbeat: TTimer;
    tsYGC: TTabSheet;
    upperPanel: TPanel;
    XMLPropStorage1: TXMLPropStorage;

    procedure acCloseExecute(Sender: TObject);
    procedure acConnectExecute(Sender: TObject);
    procedure acDeleteTextExecute(Sender: TObject);
    procedure acDisconnectExecute(Sender: TObject);
    procedure acSaveTextExecute(Sender: TObject);
    procedure acScanPortsExecute(Sender: TObject);
    procedure btnAccCaliClick(Sender: TObject);
    procedure btnAccEraseClick(Sender: TObject);
    procedure btnFrontErsClick(Sender: TObject);
    procedure btnPreFrontCaliClick(Sender: TObject);
    procedure btnRebootClick(Sender: TObject);
    procedure btnTempCaliClick(Sender: TObject);
    procedure btnTempErsClick(Sender: TObject);
    procedure btnVersionClick(Sender: TObject);
    procedure btnVibrationClick(Sender: TObject);
    procedure btnYawEncCaliClick(Sender: TObject);
    procedure btnYawEncErsClick(Sender: TObject);
    procedure btnZeroPhaseCaliClick(Sender: TObject);
    procedure btnZeroPhaseErsClick(Sender: TObject);
    procedure btnMotorTestClick(Sender: TObject);
    procedure cbPortDblClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure GIMBALtextMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GIMBALtextMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Image1Click(Sender: TObject);
    procedure timerE90HeartbeatTimer(Sender: TObject);
    procedure timerE90CommandTimer(Sender: TObject);


  private
    procedure StopAllTimer;

    procedure GridPrepare(var grid: TStringGrid; const NumRows: byte);
    procedure WriteHeader_POWER;
    procedure ClearMessageTables;
    procedure GUIsetCaptionsAndHints;
  public
    procedure ReadMessage_FD(var msg: TMAVmessage);
    procedure RecordMessage(msg: TMAVmessage; list: TStringList; LengthFixPart: byte);
    procedure ActAsGimbalChecker(var msg: TMAVmessage; list: TStringList);
    procedure ReadE90cameraMessages(msg: TMAVmessage);
    procedure NumberMessagesInStatusBar;

    procedure E90_mount_orientation(msg: TMAVmessage);
    procedure E90_gimbal_data(msg: TMAVmessage);

    procedure TempDiff(msg: TMAVmessage);
    procedure GimbalStatus(msg: TMAVmessage);
  end;

  {$I E90tool_en.inc}

var
  Form1: TForm1;
  UART: TBlockSerial;
  UARTConnected: boolean;
  starttime, MessagesSent, MessagesReceived: UInt64;
  SequNumberTransmit: byte;

const
  AppVersion='V1.1 2025-06-18';
  linkLazarus='https://www.lazarus-ide.org/';
  tab2='  ';
  maxPorts=10;
  timeout=100;

{$IFDEF WINDOWS}
  default_port='COM6';
{$ELSE}                                                {UNIX like OS}
  default_port='/dev/ttyUSB0';
{$ENDIF}


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  UARTconnected:=false;
  GIMBALtext.Lines.Clear;
  WriteHeader_POWER;
  GUIsetCaptionsAndHints;
  if ParamStr(1)='-tc' then
    panelTempCali.Visible:=true
  else
    panelTempCali.Visible:=false;
end;

procedure TForm1.GUIsetCaptionsAndHints;
begin
  Caption:=Application.Title+tab2+AppVersion;
  cbSpeed.Text:=IntToStr(defaultbaudE90);
  cbSpeed.Hint:=hntSpeed;
  cbPort.Hint:=hntPort;
  cbRecord.Caption:=capRecord;
  cbRecord.Hint:=hntRecord;

  acScanPorts.Caption:=capPort;
  acScanPorts.Hint:=hntPort;
  acDeleteText.Caption:=capDeleteText;
  acDeleteText.Hint:=hntDeleteText;
  acSaveText.Caption:=capSaveText;
  acSaveText.Hint:=hntSavetext;
  acConnect.Caption:=capConnect;
  acConnect.Hint:=hntConnect;
  acDisConnect.Caption:=capDisConnect;
  acDisConnect.Hint:=hntDisConnect;
  acClose.Caption:=capClose;

  btnVersion.Caption:=capVersion;
  btnVersion.Hint:=hntVersion;
  btnReboot.Caption:=capReboot;
  btnReboot.Hint:=hntReboot;
  btnClose.Hint:=hntClose;

  StatusBar1.Hint:=hntStatusBar;
  panelRight.Hint:=hntPanelRight;
  panelTempCali.Hint:=hntTempCali;
  lblBootTime.Hint:=hntBoottime;
  lblPowerCycle.Hint:=hntPowerCycle;
  lblWarning.Caption:=capWarning;
  tsYGC.Caption:=captsYGC;
end;

procedure TForm1.GIMBALtextMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
    GIMBALtext.Font.Size:=GIMBALtext.Font.Size-1;
end;

procedure TForm1.GIMBALtextMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
    GIMBALtext.Font.Size:=GIMBALtext.Font.Size+1;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  OpenURL(linkLazarus);
end;

function SendUARTMessage(const msg: TMAVmessage; LengthFixPart: byte): boolean;
begin
  result:=false;
  if msg.valid then begin
    if UART.SendBuffer(@msg.msgbytes, msg.msglength+LengthFixPart+2)>LengthFixPart then begin
      result:=true;
      inc(MessagesSent);
    end;
  end;
end;

procedure TForm1.GridPrepare(var grid: TStringGrid; const NumRows: byte);
var
  i: byte;

begin
  grid.RowCount:=NumRows;
  for i:=1 to NumRows-1 do
    grid.Cells[1, i]:='';
end;


procedure TForm1.WriteHeader_POWER;
begin
  GridPrepare(gridPower, 10);
  gridPower.Cells[0, 0]:='Received data';
  gridPower.Cells[1, 0]:='Value';
  gridPower.Cells[0, 1]:='Angle_X';
  gridPower.Cells[0, 2]:='Angle_Y';
  gridPower.Cells[0, 3]:='Angle_Z';
  gridPower.Cells[0, 4]:='Encode_P';
  gridPower.Cells[0, 5]:='Encode_R';
  gridPower.Cells[0, 6]:='Encode_Y';
  gridPower.Cells[0, 7]:='';
  gridPower.Cells[0, 8]:='Voltage';
  gridPower.Cells[0, 9]:='Temperature';
 end;

procedure TForm1.ClearMessageTables;
var
  i: integer;

begin
  for i:=1 to gridPower.RowCount-1 do
    gridPower.Cells[1, i];
end;

procedure IncSequNo8(var no: byte);
begin
  if no<255 then
    no:=no+1
  else
    no:=0;
end;

procedure TForm1.StopAllTimer;
begin
  timerE90Heartbeat.Enabled:=false;
  timerE90Command.Enabled:=false;
end;

procedure WriteCSVRawHeader(var list: TStringList);
var
  s: string;
  i: integer;

begin
  list.Clear;
  s:=rsTime;
  for i:=0 to 79 do
    s:=s+';'+Format('%.*d', [2, i]);
  list.Add(s);
end;

procedure SetStartValuesForGlobelVariables;
begin
  SequNumberTransmit:=0;
  MessagesSent:=0;
  MessagesReceived:=0;
  starttime:=GetTickCount64;
end;

function ConnectUART(port, speed: string): string;
begin
  result:='';
  if UARTconnected then
    exit;
  UART:=TBlockSerial.Create;
  {$IFDEF LINUX}
    UART.LinuxLock:=false;
  {$ENDIF}
  UART.Connect(port);
  sleep(200);
  UART.Config(StrToIntDef(speed, defaultbaudE90), 8, 'N', SB1, false, false); {Config default 500000 baud, 8N1}
  if UART.LastError=0 then begin
    UARTConnected:=true;
    result:='Status: '+UART.LastErrorDesc;
  end else begin
    result:='Error: '+UART.LastErrorDesc;
  end;
end;

procedure DisconnectUART;
begin
  if UARTConnected then begin
    try
      UART.CloseSocket;
    finally
      UART.Free;
      UARTConnected:=false;
    end;
  end;
end;

procedure TForm1.NumberMessagesInStatusBar;
begin
  StatusBar1.Panels[0].Text:='S: '+IntToStr(MessagesSent);
  StatusBar1.Panels[1].Text:='R: '+IntToStr(MessagesReceived);
end;

procedure TForm1.acConnectExecute(Sender: TObject);
var
  msg: TMAVmessage;
  csvlist: TStringList;

begin
  csvlist:=TStringList.Create;
  try
    msg:=Default(TMAVmessage);
    SetStartValuesForGlobelVariables;
    GIMBALtext.Lines.Clear;
    lblGimbalBootTime.Caption:='';
    StatusBar1.Panels[0].Text:='0';                    {Sent messages}
    StatusBar1.Panels[1].Text:='0';                    {Received messages}
    WriteCSVRawHeader(csvlist);
    StatusBar1.Panels[2].Text:=ConnectUART(cbPort.Text, cbSpeed.Text);

    If UARTconnected then begin
      StatusBar1.Panels[2].Text:=StatusBar1.Panels[2].Text+'  -  '+rsConnected;
      ActAsGimbalChecker(msg, csvlist);
      NumberMessagesInStatusBar;
      SaveDialog1.FilterIndex:=1;
      SaveDialog1.FileName:='FDmessages_'+FormatDateTime('yyyymmdd_hhnnss', now)+'.csv';
      if cbRecord.Checked and (csvlist.Count>1) and SaveDialog1.Execute then begin
        csvlist.SaveToFile(SaveDialog1.FileName);
        StatusBar1.Panels[2].Text:=SaveDialog1.FileName+rsSaved;
      end;
    end;
  finally
    csvlist.Free;
  end;
end;

procedure TForm1.acDeleteTextExecute(Sender: TObject);
begin
  GIMBALtext.Lines.Clear;
end;

procedure TForm1.acCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TForm1.E90_mount_orientation(msg: TMAVmessage);
var
  mount: TAttitudeData;

begin
  MOUNT_ORIENTATION(msg, LengthFixPartFD, mount);
  lblGimbalBootTime.Caption:=FormatDateTime(timeHzzz, mount.boottime);
  gridPower.Cells[1, 1]:=FormatFloat(floatformat2, mount.pitch);
  gridPower.Cells[1, 2]:=FormatFloat(floatformat2, mount.roll);
  gridPower.Cells[1, 3]:=FormatFloat(floatformat2, mount.yaw);
end;

procedure TForm1.TempDiff(msg: TMAVmessage);
begin                                            {len 31}
  gridPower.Cells[1, 9]:=FormatFloat(floatformat2 ,MavGetUInt16(msg, 39)/100)+'°C';
  // todo
end;

procedure TForm1.GimbalStatus(msg: TMAVmessage); {len different}
begin
  gridPower.Cells[1, 8]:=FormatFloat(floatformat2 ,MavGetUInt16(msg, 15)/100)+'V';
  gridPower.Cells[1, 4]:=IntToStr(MavGetInt16(msg, 21));     {Encoder data}
  gridPower.Cells[1, 5]:=IntToStr(MavGetInt16(msg, 23));
  gridPower.Cells[1, 6]:=IntToStr(MavGetInt16(msg, 25));
  // todo
end;

procedure TForm1.E90_gimbal_data(msg: TMAVmessage);
begin
  case msg.msgbytes[10] of
    1..4, 9..13, 28..31: ;
    5: TempDiff(msg);
    6: if msg.msglength>$13 then
         GimbalStatus(msg);
    $0E, $0F: GIMBALtext.Lines.Add(TextOut(msg, LengthFixPartFD+9, msg.msglength-9));
    $FE: if msg.msglength>1 then
           GIMBALtext.Lines.Add(TextOut(msg, LengthFixPartFD+1, msg.msglength-1));
  else
    GIMBALtext.Lines.Add('Unknown gimbal message type: 0x'+
                         IntToHex(msg.msgbytes[10], 2)+tab2+
                         ' = '+IntToStr(msg.msgbytes[10]));
  end;
end;

procedure TForm1.ReadE90cameraMessages(msg: TMAVmessage);
begin
  case msg.msgid32 of
    0, 76: ;
    265: E90_mount_orientation(msg);
    5002: E90_gimbal_data(msg);
  else
    GIMBALtext.Lines.Add('Unknown message ID: 0x'+
                         IntToHex(msg.msgbytes[8], 2)+tab2+
                         ' = '+IntToStr(msg.msgbytes[8]));
  end;
end;

procedure TForm1.RecordMessage(msg: TMAVmessage; list: TStringList; LengthFixPart: byte);
var
  s: string;
  i: integer;

begin
  s:=FormatFloat(floatformat3, (GetTickCount64-starttime)/1000);
  for i:=0 to msg.msglength+LengthFixPart+1 do begin
    s:=s+';'+IntToHex(msg.msgbytes[i], 2);
  end;
  list.Add(s);
end;

function FormatBootTime(const data: TGPSdata): string;
begin
  result:=FormatDateTime(timezzz, data.boottime);
end;

procedure SendE90Command(const CommandCode: byte);
var
  msg: TMAVmessage;

begin
  if UARTConnected then begin
    CreateE90commandMessage(msg, SequNumberTransmit, CommandCode);
    if SendUARTMessage(msg, LengthFixPartFD) then
      IncSequNo8(SequNumberTransmit);
  end;
end;

{PID buttons:
 06 Read PID
 07 Save PID
 08 Reset PD  says OK but no effect seen

 after Read PID send a lot of commands 1, 2, 3 with values but effect??

 1C Data rate set }

procedure TForm1.ActAsGimbalChecker(var msg: TMAVmessage; list: TStringList);
begin
  ClearMessageTables;
  timerE90Heartbeat.Enabled:=true;
  timerE90Command.Enabled:=true;
//  SendE90Command(6);           {Read PID}

  while (UART.LastError=0) and UARTConnected do begin
    if UART.CanRead(0) then begin
      ReadMessage_FD(msg);
      if msg.valid then begin
        ReadE90CameraMessages(msg);

        if cbRecord.Checked then
          RecordMessage(msg, list, LengthFixPartFD);
        inc(MessagesReceived);
      end;
    end;
    Application.ProcessMessages;
  end;
end;

procedure TForm1.ReadMessage_FD(var msg: TMAVmessage);
var
  b: byte;
  i: integer;

begin
  msg.valid:=false;
  repeat
    b:=UART.RecvByte(timeout);
  until (b=MagicFD) or (UART.LastError<>0) or (not UARTConnected);
  msg.msgbytes[0]:=b;
  msg.msglength:=UART.RecvByte(timeout);
  msg.msgbytes[1]:=msg.msglength;
  for i:=2 to msg.msglength+LengthFixPartFD+1 do
    msg.msgbytes[i]:=UART.RecvByte(timeout);

  msg.msgid32:=MAVgetUInt32(msg, 7) and $FFFFFF;
  if CheckCRC16MAV(msg, LengthFixPartFD, 1, true, GetCRCextra(msg.msgid32)) then begin
    msg.sysid:=msg.msgbytes[5];
    msg.targetid:=msg.msgbytes[6];
    msg.msgid:=msg.msgbytes[7];
    msg.valid:=true;
  end;
end;


procedure TForm1.acDisconnectExecute(Sender: TObject);
begin
  StopAllTimer;
  DisconnectUART;
  StatusBar1.Panels[2].Text:=rsDisconnected;
end;

procedure TForm1.acSaveTextExecute(Sender: TObject);
begin
  SaveDialog1.Title:=titSaveText;
  SaveDialog1.FilterIndex:=2;
  SaveDialog1.FileName:=FormatDateTime('yyyymmdd_hhnnss', now)+'.txt';
  if SaveDialog1.Execute then
    GIMBALtext.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.acScanPortsExecute(Sender: TObject);
var
{$IFDEF UNIX}
  cmd: TProcess;
  list: TStringList;
{$ENDIF}
  i: integer;

begin
{$IFDEF WINDOWS}
  cbPort.Text:='';
  cbPort.Items.Clear;
  GimbalText.Lines.Clear;
  cbPort.Items.CommaText:=GetSerialPortNames;
  if cbPort.Items.Count>0 then begin
    cbPort.Text:=cbPort.Items[cbPort.Items.Count-1];
    for i:=0 to  cbPort.Items.Count-1 do begin
      GIMBALtext.Lines.Add(cbPort.Items[i]);
    end;
    StatusBar1.Panels[2].Text:=cbPort.Items[cbPort.Items.Count-1];
  end else
    StatusBar1.Panels[2].Text:=errNoUSBport;

{$ENDIF}
{$IFDEF UNIX}
  cmd:=TProcess.Create(nil);
  list:=TStringList.Create;
  try
    GIMBALtext.Lines.Clear;
    cmd.Options:=cmd.Options+[poWaitOnExit, poUsePipes];
    cmd.Executable:='ls';
    for i:=0 to cbPort.Items.count-1 do begin
      cmd.Parameters.Clear;
      cmd.Parameters.Add(cbPort.Items[i]);
      cmd.Execute;
      list.LoadFromStream(cmd.Output);
      if list.Count>0 then begin
        StatusBar1.Panels[2].Text:=list[0];
        GIMBALtext.Lines.Add(list[0]);
      end;
    end;
    if GIMBALtext.Lines.Count<1 then
      StatusBar1.Panels[2].Text:=errNoUSBport;
  finally
    cmd.Free;
    list.Free;
  end;
{$ENDIF}
end;

procedure TForm1.btnYawEncErsClick(Sender: TObject);
begin
  SendE90Command($0D);
end;

procedure TForm1.btnZeroPhaseErsClick(Sender: TObject);
begin
  SendE90Command($11);
end;

procedure TForm1.btnMotorTestClick(Sender: TObject);
begin
  SendE90Command($1E);
end;

procedure TForm1.btnAccEraseClick(Sender: TObject);
begin
  SendE90Command($13);
end;

procedure TForm1.btnFrontErsClick(Sender: TObject);
begin
  SendE90Command($15);
end;

procedure TForm1.btnYawEncCaliClick(Sender: TObject);
begin
  SendE90Command($0C);
end;

procedure TForm1.btnPreFrontCaliClick(Sender: TObject);
begin
  SendE90Command($0F);
end;

procedure TForm1.btnRebootClick(Sender: TObject);
begin
  SendE90Command($19);
end;

procedure TForm1.btnTempCaliClick(Sender: TObject);
begin
  SendE90Command($09);
end;

procedure TForm1.btnTempErsClick(Sender: TObject);
begin
  SendE90Command($0A);
end;

procedure TForm1.btnZeroPhaseCaliClick(Sender: TObject);
begin
  SendE90Command($10);
end;

procedure TForm1.btnAccCaliClick(Sender: TObject);
begin
  SendE90Command($12);
end;

procedure TForm1.btnVersionClick(Sender: TObject);
begin
  SendE90Command($18);
end;

procedure TForm1.btnVibrationClick(Sender: TObject);
begin
  SendE90Command($20);
end;

procedure TForm1.cbPortDblClick(Sender: TObject);
begin
  acScanPortsExecute(self);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  if not UARTconnected then begin
    StopAllTimer;
    acScanPortsExecute(self);
    btnConnect.SetFocus;
  end;
end;

procedure TForm1.timerE90HeartbeatTimer(Sender: TObject);
var
  msg: TMAVmessage;

begin
  if UARTConnected then begin
    CreateE90HeartBeat(msg, SequNumberTransmit);
    if SendUARTMessage(msg, LengthFixPartFD) then
      IncSequNo8(SequNumberTransmit);
  end;
  NumberMessagesInStatusBar;
end;

procedure TForm1.timerE90CommandTimer(Sender: TObject);
begin
  SendE90Command($FE);
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  DisconnectUART;
end;

end.

