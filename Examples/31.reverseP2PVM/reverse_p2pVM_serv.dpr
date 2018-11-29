program reverse_p2pVM_serv;

{$APPTYPE CONSOLE}

{$R *.res}

{
  P2PVM�ǻ���IO����������������Է������Ϳͻ���ģ��û��Ҫ��
  ����˵��
  P2PVM�������Ϳͻ��˿��Թ����������ͻ���Ҳ�ܹ���������������
  ֻҪ��IO���ڣ�P2PVM���ܹ���
  �����������P2PVM���̨�������������ռ佫��ǳ������������κ����绷��
}

uses
  SysUtils,
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF MSWINDOWS}
  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  CommunicationFramework,
  PhysicsIO,
  DoStatusIO;

{
  ��Demo���ȴ���һ�������ͻ��ˣ�Ȼ���������ͻ��˻���������P2PVM�ķ�����
}
type
  TMyP2PVM_Server = class(TCommunicationFrameworkWithP2PVM_Server)
  public
  end;

var
  MyP2PVM_Server: TMyP2PVM_Server;

type
  TMyPhysics_Client = class(TPhysicsClient)
  public
    procedure p2pVMTunnelAuth(Sender: TPeerIO; const Token: SystemString; var Accept: Boolean); override;
    procedure p2pVMTunnelOpenBefore(Sender: TPeerIO; p2pVMTunnel: TCommunicationFrameworkWithP2PVM); override;
    procedure p2pVMTunnelOpen(Sender: TPeerIO; p2pVMTunnel: TCommunicationFrameworkWithP2PVM); override;
    procedure p2pVMTunnelOpenAfter(Sender: TPeerIO; p2pVMTunnel: TCommunicationFrameworkWithP2PVM); override;
    procedure p2pVMTunnelClose(Sender: TPeerIO; p2pVMTunnel: TCommunicationFrameworkWithP2PVM); override;
  end;

procedure TMyPhysics_Client.p2pVMTunnelAuth(Sender: TPeerIO; const Token: SystemString; var Accept: Boolean);
begin
  inherited;
  // p2pVM�����ֲ���1:Զ����֤
  Accept := True;
end;

procedure TMyPhysics_Client.p2pVMTunnelOpenBefore(Sender: TPeerIO; p2pVMTunnel: TCommunicationFrameworkWithP2PVM);
begin
  inherited;
  DoStatus('P2PVM OpenBefore �����IP: %s', [Sender.PeerIP]);
  Sender.p2pVM.QuietMode := True;
  Sender.p2pVM.InstallLogicFramework(MyP2PVM_Server);
end;

procedure TMyPhysics_Client.p2pVMTunnelOpen(Sender: TPeerIO; p2pVMTunnel: TCommunicationFrameworkWithP2PVM);
begin
  inherited;
  DoStatus('P2PVM Open �����IP: %s', [Sender.PeerIP]);
end;

procedure TMyPhysics_Client.p2pVMTunnelOpenAfter(Sender: TPeerIO; p2pVMTunnel: TCommunicationFrameworkWithP2PVM);
begin
  inherited;
  DoStatus('P2PVM OpenAfter �����IP: %s', [Sender.PeerIP]);
end;

procedure TMyPhysics_Client.p2pVMTunnelClose(Sender: TPeerIO; p2pVMTunnel: TCommunicationFrameworkWithP2PVM);
begin
  inherited;
  DoStatus('P2PVM Close �����IP: %s', [Sender.PeerIP]);
  Sender.p2pVM.UninstallLogicFramework(MyP2PVM_Server);
end;

var
  MyPhysics_Client: TMyPhysics_Client;

begin
  MyP2PVM_Server := TMyP2PVM_Server.Create;
  MyP2PVM_Server.StartService('::', 99);
  MyP2PVM_Server.QuietMode := True;

  MyPhysics_Client := TMyPhysics_Client.Create;

  while True do
    begin
      if not MyPhysics_Client.Connected then
        while not MyPhysics_Client.Connect('127.0.0.1', 19899) do
            CoreClasses.CheckThreadSynchronize(100);

      // ��p2pVM��InstallLogicFramework��progress���Զ�����MyP2PVM_Server.Progress
      if MyPhysics_Client.Connected then
          MyPhysics_Client.Progress;

{$IFDEF MSWINDOWS}
      SetConsoleTitle(PWideChar(Format('P2PVM server online: %d', [MyP2PVM_Server.Count])));
{$ENDIF MSWINDOWS}
      // ��ɫ��������cpu����
      CoreClasses.CheckThreadSynchronize(10);
    end;

end.